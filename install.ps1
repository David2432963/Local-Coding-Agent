# Local Coding Agent
# Copyright (c) 2026 Long Nguyen
# SPDX-License-Identifier: AGPL-3.0-or-later

$ErrorActionPreference = "Stop"

# Install server dependencies using the checked-in setup.json.
# Edit setup.json yourself, then use start-server.bat to run the agent.
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Launcher = Join-Path $RepoRoot "scripts\local-coding-agent.mjs"
$ConfigPath = Join-Path $RepoRoot "setup.json"
$Node = Get-Command node.exe -ErrorAction SilentlyContinue

if (-not $Node) {
    throw "Node.js 18 or newer is required and must be available on PATH."
}
$NodeVersion = (& $Node.Source --version).Trim()
if ($LASTEXITCODE -ne 0 -or $NodeVersion -notmatch '^v?(\d+)\.') {
    throw "Could not determine the installed Node.js version. Install Node.js 18 or newer."
}
if ([int]$Matches[1] -lt 18) {
    throw "Node.js 18 or newer is required. Found $NodeVersion."
}
if (-not (Test-Path -LiteralPath $Launcher)) {
    throw "Local Coding Agent launcher not found: $Launcher"
}
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Project setup file not found: $ConfigPath. Restore setup.json from the repository."
}

$env:LCA_CONFIG_PATH = $ConfigPath
& $Node.Source $Launcher install
if ($LASTEXITCODE -ne 0) {
    throw "Local Coding Agent install failed with exit code $LASTEXITCODE."
}

Write-Host ""
Write-Host "Installation complete. Edit your settings here:"
Write-Host "  $ConfigPath"
Write-Host "Then run start-server.bat."
