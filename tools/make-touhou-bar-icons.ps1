# Create compact Touhou icons from the downloaded 256x1536 sprite sheets.
# The pack stores six 256x256 frames vertically. We use the first frame,
# crop its non-transparent bounds, and fit it into a 24x24 transparent PNG.

Add-Type -AssemblyName System.Drawing

$root = Join-Path $PSScriptRoot "..\assets\yasb\touhou"

$map = [ordered]@{
    "bllm.png" = "bar_reimu.png"
    "mls.png"  = "bar_marisa.png"
    "qln.png"  = "bar_cirno.png"
    "xy.png"   = "bar_sakuya.png"
    "lmly.png" = "bar_remilia.png"
}

foreach ($pair in $map.GetEnumerator()) {
    $sourcePath = Join-Path $root $pair.Key
    $outputPath = Join-Path $root $pair.Value

    if (-not (Test-Path $sourcePath)) {
        throw "Missing sprite sheet: $sourcePath"
    }

    $src = [System.Drawing.Bitmap]::new($sourcePath)

    try {
        if ($src.Width -ne 256 -or $src.Height -lt 256) {
            throw "$($pair.Key) is $($src.Width)x$($src.Height), expected a 256px-wide sprite sheet."
        }

        # First 256x256 frame.
        $frame = [System.Drawing.Bitmap]::new(256, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $g = [System.Drawing.Graphics]::FromImage($frame)
            try {
                $g.Clear([System.Drawing.Color]::Transparent)
                $g.DrawImage(
                    $src,
                    [System.Drawing.Rectangle]::new(0, 0, 256, 256),
                    [System.Drawing.Rectangle]::new(0, 0, 256, 256),
                    [System.Drawing.GraphicsUnit]::Pixel
                )
            }
            finally {
                $g.Dispose()
            }

            # Find the non-transparent bounding box.
            $minX = 255; $minY = 255; $maxX = 0; $maxY = 0; $found = $false

            for ($y = 0; $y -lt 256; $y++) {
                for ($x = 0; $x -lt 256; $x++) {
                    $a = $frame.GetPixel($x, $y).A
                    if ($a -gt 8) {
                        $found = $true
                        if ($x -lt $minX) { $minX = $x }
                        if ($y -lt $minY) { $minY = $y }
                        if ($x -gt $maxX) { $maxX = $x }
                        if ($y -gt $maxY) { $maxY = $y }
                    }
                }
            }

            if (-not $found) {
                throw "The first frame of $($pair.Key) is fully transparent."
            }

            $pad = 4
            $minX = [Math]::Max(0, $minX - $pad)
            $minY = [Math]::Max(0, $minY - $pad)
            $maxX = [Math]::Min(255, $maxX + $pad)
            $maxY = [Math]::Min(255, $maxY + $pad)

            $cropW = $maxX - $minX + 1
            $cropH = $maxY - $minY + 1

            $out = [System.Drawing.Bitmap]::new(28, 28, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            try {
                $go = [System.Drawing.Graphics]::FromImage($out)
                try {
                    $go.Clear([System.Drawing.Color]::Transparent)
                    $go.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                    $go.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
                    $go.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None

                    $scale = [Math]::Min(24.0 / $cropW, 24.0 / $cropH)
                    $dw = [Math]::Max(1, [int][Math]::Round($cropW * $scale))
                    $dh = [Math]::Max(1, [int][Math]::Round($cropH * $scale))
                    $dx = [int][Math]::Floor((28 - $dw) / 2)
                    $dy = [int][Math]::Floor((28 - $dh) / 2)

                    $go.DrawImage(
                        $frame,
                        [System.Drawing.Rectangle]::new($dx, $dy, $dw, $dh),
                        [System.Drawing.Rectangle]::new($minX, $minY, $cropW, $cropH),
                        [System.Drawing.GraphicsUnit]::Pixel
                    )
                }
                finally {
                    $go.Dispose()
                }

                $out.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
            }
            finally {
                $out.Dispose()
            }
        }
        finally {
            $frame.Dispose()
        }
    }
    finally {
        $src.Dispose()
    }

    Write-Host "Created $($pair.Value)"
}

Write-Host ""
Write-Host "Touhou bar icons created in $root"
