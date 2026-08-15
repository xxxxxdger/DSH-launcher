# install.ps1 - create or remove a desktop shortcut for the DeepSeek Harness launcher.
# Usage:
#   .\install.ps1            # create the desktop shortcut
#   .\install.ps1 -Remove    # remove the desktop shortcut
# ASCII-only on purpose: PowerShell 5.1 (see harness.ps1).

param(
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'

$desktop = [Environment]::GetFolderPath('Desktop')
$lnk     = Join-Path $desktop 'DeepSeek Harness.lnk'
$vbs     = Join-Path $PSScriptRoot 'harness.vbs'
$ico     = Join-Path $PSScriptRoot 'icon.ico'

if ($Remove) {
    if (Test-Path -LiteralPath $lnk) {
        Remove-Item -LiteralPath $lnk -Force
        Write-Host "Removed: $lnk"
    } else {
        Write-Host 'No shortcut found.'
    }
    exit 0
}

if (-not (Test-Path -LiteralPath $vbs)) {
    throw "harness.vbs not found next to this script: $vbs"
}

$wsh = New-Object -ComObject WScript.Shell
$sc  = $wsh.CreateShortcut($lnk)
$sc.TargetPath       = $vbs
$sc.WorkingDirectory = $PSScriptRoot
$sc.IconLocation     = $ico
$sc.Description      = 'Toggle the DeepSeek Harness Web GUI (start / stop).'
$sc.Save()

Write-Host "Shortcut created: $lnk"
