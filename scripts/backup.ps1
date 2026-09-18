$ErrorActionPreference = "Stop"

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$root = Join-Path $HOME "Desktop\remilia-backup-$stamp"
New-Item -ItemType Directory -Path $root -Force | Out-Null

$glaze = Join-Path $HOME ".glzr\glazewm\config.yaml"
$terminal = Join-Path $HOME "AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$profile = Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $glaze) {
    Copy-Item $glaze (Join-Path $root "glazewm-config.yaml") -Force
}

if (Test-Path $terminal) {
    Copy-Item $terminal (Join-Path $root "windows-terminal-settings.json") -Force
}

if (Test-Path $profile) {
    Copy-Item $profile (Join-Path $root "powershell-profile.ps1") -Force
}

Write-Host "backup created: $root" -ForegroundColor Green
