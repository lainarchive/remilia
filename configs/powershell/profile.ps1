# Remilia PowerShell profile
# Portable repo-backed startup for Fastfetch + Oh My Posh.

$RemiliaRoot = Join-Path $env:USERPROFILE 'remilia'
$FastfetchConfig = Join-Path $RemiliaRoot 'configs\fastfetch\config.jsonc'
$OhMyPoshTheme = Join-Path $RemiliaRoot 'configs\oh-my-posh\remilia.omp.json'

# Fastfetch
if ((Get-Command fastfetch -ErrorAction SilentlyContinue) -and
    (Test-Path -LiteralPath $FastfetchConfig)) {
    fastfetch --config $FastfetchConfig
}

# Oh My Posh
if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and
    (Test-Path -LiteralPath $OhMyPoshTheme)) {
    oh-my-posh init pwsh --config $OhMyPoshTheme | Invoke-Expression
}

function dev {
    & "C:\Scripts\dev\dev.ps1" @args
}

# ==========================================
# Remilia PowerShell — PSReadLine
# ==========================================

Import-Module PSReadLine

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function NextWord

Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 10000

Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
