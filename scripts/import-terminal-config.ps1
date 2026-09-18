# Import the user's already-working terminal assets into Remilia.
# This copies, but does not modify, the current Fastfetch and Oh My Posh files.

$repoRoot = Split-Path -Parent $PSScriptRoot

$fastfetchSource = 'C:\Scripts\fastfetch-configs\fastfetch-ricing'
$fastfetchTarget = Join-Path $repoRoot 'configs\fastfetch'

$ompSource = 'C:\Users\User\.miku.omp.json'
$ompTarget = Join-Path $repoRoot 'configs\oh-my-posh\remilia.omp.json'

$requiredFastfetch = @(
    (Join-Path $fastfetchSource 'config.jsonc'),
    (Join-Path $fastfetchSource 'manga.six')
)

foreach ($path in $requiredFastfetch) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing Fastfetch file: $path"
    }
}

if (-not (Test-Path -LiteralPath $ompSource)) {
    throw "Missing Oh My Posh theme: $ompSource"
}

New-Item -ItemType Directory -Force $fastfetchTarget | Out-Null
New-Item -ItemType Directory -Force (Split-Path $ompTarget) | Out-Null

Copy-Item -LiteralPath (Join-Path $fastfetchSource 'config.jsonc') -Destination $fastfetchTarget -Force
Copy-Item -LiteralPath (Join-Path $fastfetchSource 'manga.six') -Destination $fastfetchTarget -Force
Copy-Item -LiteralPath $ompSource -Destination $ompTarget -Force

Write-Host ''
Write-Host 'Imported terminal configs into Remilia:' -ForegroundColor Green
Write-Host "  Fastfetch: $fastfetchTarget"
Write-Host "  Oh My Posh: $ompTarget"
Write-Host ''
Write-Host 'Review the files, then commit them with git.' -ForegroundColor Cyan
