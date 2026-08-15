# DeepSeek Harness launcher (toggle).
# One shortcut does both jobs:
#   - if the Web GUI is not running: start `dsh web` hidden, wait for it,
#     then open the browser;
#   - if it is already running: stop the dsh process family.
# ASCII-only on purpose: Windows PowerShell 5.1 reads scripts without a
# BOM as ANSI, which would garble non-ASCII text.
#
# Usage:
#   .\harness.ps1                 # toggle start/stop on the default port 3080
#   .\harness.ps1 -Port 8080      # use a different port

param(
    [int]$Port = 3080
)

$ErrorActionPreference = 'SilentlyContinue'

# ---- configuration ----
$Loopback = '127.0.0.1'
$Url      = "http://${Loopback}:${Port}"

# ---- helpers ----
function Find-DshCmd {
    # 1) global npm install (the normal, permanent location)
    $global = Join-Path $env:APPDATA 'npm\dsh.cmd'
    if (Test-Path -LiteralPath $global) { return $global }

    # 2) newest npx cache checkout as a fallback
    $npxRoot = Join-Path $env:LOCALAPPDATA 'npm-cache\_npx'
    if (Test-Path -LiteralPath $npxRoot) {
        $candidates = Get-ChildItem -LiteralPath $npxRoot -Directory |
            ForEach-Object { Join-Path $_.FullName 'node_modules\.bin\dsh.cmd' } |
            Where-Object { Test-Path -LiteralPath $_ }
        if ($candidates) { return ($candidates | Select-Object -First 1) }
    }
    return $null
}

function Test-ServerUp {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $iar = $client.BeginConnect($Loopback, $Port, $null, $null)
        return $iar.AsyncWaitHandle.WaitOne(500)
    } finally {
        $client.Close()
    }
}

function Show-Msg([string]$text) {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.MessageBox]::Show($text, 'DeepSeek Harness', 0, 64) | Out-Null
}

function Start-Harness {
    $dsh = Find-DshCmd
    if (-not $dsh) {
        Show-Msg 'Cannot find the dsh command. Please install it with: npm install -g @deepseek-ai/dsh'
        return
    }

    # Start the server in a hidden window.
    Start-Process -FilePath $dsh -ArgumentList 'web' -WindowStyle Hidden | Out-Null

    # Wait for the server to come up (up to ~30 seconds).
    $deadline = (Get-Date).AddSeconds(30)
    $up = $false
    while ((Get-Date) -lt $deadline) {
        if (Test-ServerUp) { $up = $true; break }
        Start-Sleep -Milliseconds 500
    }

    if ($up) {
        Start-Process $Url
    } else {
        Show-Msg 'The Harness server did not come up in time. Check the terminal output of dsh web for errors.'
    }
}

function Stop-Harness {
    # ---- collect candidate PIDs ----
    $targets = @()

    # 1) node processes running the dsh CLI (precise, no unrelated node apps hit)
    $procs = Get-CimInstance Win32_Process -Filter "Name = 'node.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like '*@deepseek-ai\dsh\lib\bin.js*' }
    foreach ($p in $procs) { $targets += [int]$p.ProcessId }

    # 2) the process listening on the GUI port (always works via netstat)
    $rows = netstat -ano | Select-String (":$Port\s+.*LISTENING")
    foreach ($row in $rows) {
        $line = $row.ToString()
        if ($line -match 'LISTENING\s+(\d+)\s*$') {
            $targets += [int]$Matches[1]
        }
    }

    $targets = @($targets | Select-Object -Unique)

    if ($targets.Count -eq 0) {
        Show-Msg 'DeepSeek Harness is not running.'
        return
    }

    foreach ($id in $targets) {
        Stop-Process -Id $id -Force -ErrorAction SilentlyContinue
    }

    Start-Sleep -Milliseconds 1000

    # ---- verify ----
    $listenersLeft = (netstat -ano | Select-String (":$Port\s+.*LISTENING") | Measure-Object).Count
    $stillAlive = @()
    foreach ($id in $targets) {
        if (Get-Process -Id $id -ErrorAction SilentlyContinue) { $stillAlive += $id }
    }

    if ($listenersLeft -eq 0 -and $stillAlive.Count -eq 0) {
        Show-Msg 'DeepSeek Harness has been stopped.'
    } elseif ($listenersLeft -eq 0) {
        Show-Msg 'The Harness server was stopped; background processes are closing and will exit shortly.'
    } else {
        Show-Msg 'DeepSeek Harness could not be stopped. Close the process manually in Task Manager.'
    }
}

# ---- main: toggle ----
if (Test-ServerUp) {
    Stop-Harness
} else {
    Start-Harness
}
exit 0
