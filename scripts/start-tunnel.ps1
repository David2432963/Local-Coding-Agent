# Local Coding Agent
# Copyright (c) 2026 Long Nguyen
# SPDX-License-Identifier: AGPL-3.0-or-later

$ErrorActionPreference = "Stop"

# Keep the project-local setup file as the default while allowing an explicit
# LCA_CONFIG_PATH override for users who maintain a separate config.
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not $env:LCA_CONFIG_PATH) {
    $env:LCA_CONFIG_PATH = Join-Path $RepoRoot "setup.json"
}

$Node = Get-Command node.exe -ErrorAction SilentlyContinue
if (-not $Node) {
    throw "Node.js 18 or newer is required and must be available on PATH."
}

$Launcher = Join-Path $RepoRoot "scripts\local-coding-agent.mjs"
if (-not (Test-Path -LiteralPath $env:LCA_CONFIG_PATH)) {
    throw "Setup file not found: $env:LCA_CONFIG_PATH. Run install.bat first."
}

& $Node.Source $Launcher start @args
exit $LASTEXITCODE
