param(
    [Parameter(Mandatory = $true)]
    [string]$BackupPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BackupPath)) {
    throw "backup path does not exist: $BackupPath"
}

$glaze = Join-Path $HOME ".glzr\glazewm\config.yaml"
$terminal = Join-Path $HOME "AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$profile = Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

$items = @(
    @{ Source = "glazewm-config.yaml"; Target = $glaze },
    @{ Source = "windows-terminal-settings.json"; Target = $terminal },
    @{ Source = "powershell-profile.ps1"; Target = $profile }
)

foreach ($item in $items) {
    $source = Join-Path $BackupPath $item.Source
    if (Test-Path $source) {
        Copy-Item $source $item.Target -Force
        Write-Host "restored $($item.Source)" -ForegroundColor Green
    }
}

Write-Host "restore complete. restart affected applications before testing." -ForegroundColor Green
