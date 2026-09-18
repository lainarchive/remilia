# Fastfetch Eagle startup
$eagleFastfetchRoot = 'C:\Scripts\fastfetch-configs\fastfetch-ricing'
$eagleFastfetchConfig = Join-Path $eagleFastfetchRoot 'config.jsonc'

if ((Get-Command fastfetch -ErrorAction SilentlyContinue) -and
    (Test-Path -LiteralPath $eagleFastfetchConfig)) {
    $env:FASTFETCH_EAGLE_ROOT = $eagleFastfetchRoot
    fastfetch --config $eagleFastfetchConfig
}

# Oh My Posh
oh-my-posh init pwsh --config "C:\Users\User\.miku.omp.json" | Invoke-Expression


function dev {
    & "C:\Scripts\dev\dev.ps1" @args
}
# ==========================================
# CactusOS PowerShell — PSReadLine
# ==========================================

Import-Module PSReadLine

# Smarter history navigation
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Better word navigation
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function NextWord

# History behavior
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 10000

# Inline command predictions
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
