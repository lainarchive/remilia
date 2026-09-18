# Build clean 28x28 YASB icons from the Touhou sprite sheets in:
# assets\\yasb\\touhou
#
# Each source is a 256x1536 vertical sheet containing six 256x256 frames.
# The script evaluates every frame instead of assuming frame 1 is usable.

Add-Type -AssemblyName System.Drawing

$root = Join-Path $PSScriptRoot "..\assets\yasb\touhou"

$map = [ordered]@{
    "bllm.png" = "bar_reimu.png"
    "mls.png"  = "bar_marisa.png"
    "qln.png"  = "bar_cirno.png"
    "xy.png"   = "bar_sakuya.png"
    "lmly.png" = "bar_remilia.png"
    "fldl.png" = "bar_flandre.png"
    "hml.png"  = "bar_meiling.png"
    "pql.png"  = "bar_patchouli.png"
    "xem.png"  = "bar_koakuma.png"
    "dyj.png"  = "bar_daiyousei.png"
}

function Get-FrameBounds {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [int]$Y
    )

    # Sample several corners to determine whether the sheet uses
    # transparent or opaque background.
    $samples = @(
        $Bitmap.GetPixel(0, $Y)
        $Bitmap.GetPixel(255, $Y)
        $Bitmap.GetPixel(0, [Math]::Min($Y + 255, $Bitmap.Height - 1))
        $Bitmap.GetPixel(255, [Math]::Min($Y + 255, $Bitmap.Height - 1))
    )

    $transparentBackground = (($samples | Where-Object { $_.A -le 10 }).Count -ge 2)

    $minX = 255
    $minY = 255
    $maxX = 0
    $maxY = 0
    $count = 0

    $bgR = 0
    $bgG = 0
    $bgB = 0

    if (-not $transparentBackground) {
        $bgR = [int](($samples | Measure-Object -Property R -Average).Average)
        $bgG = [int](($samples | Measure-Object -Property G -Average).Average)
        $bgB = [int](($samples | Measure-Object -Property B -Average).Average)
    }

    for ($py = 0; $py -lt 256; $py++) {
        $actualY = $Y + $py

        for ($px = 0; $px -lt 256; $px++) {
            $c = $Bitmap.GetPixel($px, $actualY)

            $content = $false

            if ($transparentBackground) {
                $content = $c.A -gt 12
            }
            else {
                $dr = [math]::Abs([int]$c.R - $bgR)
                $dg = [math]::Abs([int]$c.G - $bgG)
                $db = [math]::Abs([int]$c.B - $bgB)

                # Ignore tiny compression/color noise.
                $content = (($dr + $dg + $db) -ge 28)
            }

            if ($content) {
                $count++

                if ($px -lt $minX) { $minX = $px }
                if ($py -lt $minY) { $minY = $py }
                if ($px -gt $maxX) { $maxX = $px }
                if ($py -gt $maxY) { $maxY = $py }
            }
        }
    }

    if ($count -eq 0) {
        return [pscustomobject]@{
            HasContent = $false
            Count = 0
            Area = 0
            X = 0
            Y = $Y
            Width = 0
            Height = 0
        }
    }

    $w = $maxX - $minX + 1
    $h = $maxY - $minY + 1

    [pscustomobject]@{
        HasContent = $true
        Count = $count
        Area = $w * $h
        X = $minX
        Y = $Y + $minY
        Width = $w
        Height = $h
    }
}

foreach ($pair in $map.GetEnumerator()) {
    $sourcePath = Join-Path $root $pair.Key
    $outputPath = Join-Path $root $pair.Value

    if (-not (Test-Path $sourcePath)) {
        throw "Missing sprite sheet: $sourcePath"
    }

    $src = [System.Drawing.Bitmap]::new($sourcePath)

    try {
        if ($src.Width -ne 256 -or $src.Height -lt 1536) {
            throw "$($pair.Key) is $($src.Width)x$($src.Height), expected 256x1536."
        }

        $frames = @()

        for ($frameIndex = 0; $frameIndex -lt 6; $frameIndex++) {
            $frameY = $frameIndex * 256
            $bounds = Get-FrameBounds -Bitmap $src -Y $frameY

            if ($bounds.HasContent) {
                # Favor frames with a substantial silhouette.
                $score = [math]::Sqrt($bounds.Area) * [math]::Log([math]::Max(2, $bounds.Count), 2)
                $bounds | Add-Member -NotePropertyName Score -NotePropertyValue $score
                $bounds | Add-Member -NotePropertyName Frame -NotePropertyValue $frameIndex
                $frames += $bounds
            }
        }

        if ($frames.Count -eq 0) {
            throw "No visible character content detected in $($pair.Key)."
        }

        $best = $frames | Sort-Object Score -Descending | Select-Object -First 1

        $pad = 8
        $cropX = [math]::Max(0, $best.X - $pad)
        $cropY = [math]::Max(0, $best.Y - $pad)
        $cropRight = [math]::Min($src.Width - 1, $best.X + $best.Width - 1 + $pad)
        $cropBottom = [math]::Min($src.Height - 1, $best.Y + $best.Height - 1 + $pad)
        $cropW = $cropRight - $cropX + 1
        $cropH = $cropBottom - $cropY + 1

        $out = [System.Drawing.Bitmap]::new(28, 28, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

        try {
            $g = [System.Drawing.Graphics]::FromImage($out)
            try {
                $g.Clear([System.Drawing.Color]::Transparent)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
                $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
                $g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy

                $scale = [math]::Min(24.0 / $cropW, 24.0 / $cropH)
                $drawW = [math]::Max(1, [int][math]::Round($cropW * $scale))
                $drawH = [math]::Max(1, [int][math]::Round($cropH * $scale))
                $drawX = [int][math]::Floor((28 - $drawW) / 2)
                $drawY = [int][math]::Floor((28 - $drawH) / 2)

                $g.DrawImage(
                    $src,
                    [System.Drawing.Rectangle]::new($drawX, $drawY, $drawW, $drawH),
                    [System.Drawing.Rectangle]::new($cropX, $cropY, $cropW, $cropH),
                    [System.Drawing.GraphicsUnit]::Pixel
                )
            }
            finally {
                $g.Dispose()
            }

            $out.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $out.Dispose()
        }

        Write-Host ("{0} -> frame {1} -> {2}x{3}" -f $pair.Key, $best.Frame + 1, $best.Width, $best.Height)
    }
    finally {
        $src.Dispose()
    }
}

Write-Host ""
Write-Host "Created 10 Touhou bar icons."
