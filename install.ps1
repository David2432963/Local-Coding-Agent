# Local Coding Agent
# Copyright (c) 2026 Long Nguyen
# SPDX-License-Identifier: AGPL-3.0-or-later

$ErrorActionPreference = "Stop"

# Install dependencies and prepare the single project-local setup.json.
# Edit setup.json yourself, then use start-server.bat to run the agent.
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Launcher = Join-Path $RepoRoot "scripts\local-coding-agent.mjs"
$ConfigPath = Join-Path $RepoRoot "setup.json"
$LegacyConfigPath = Join-Path $env:APPDATA "LocalCodingAgent\cli-config.json"
$Node = Get-Command node.exe -ErrorAction SilentlyContinue

if (-not $Node) {
    throw "Node.js 18 or newer is required and must be available on PATH."
}
if (-not (Test-Path -LiteralPath $Launcher)) {
    throw "Local Coding Agent launcher not found: $Launcher"
}

$env:LCA_CONFIG_PATH = $ConfigPath
& $Node.Source $Launcher install
if ($LASTEXITCODE -ne 0) {
    throw "Local Coding Agent install failed with exit code $LASTEXITCODE."
}

# Move any saved legacy values into empty fields without deleting the source
# config or replacing values already edited in setup.json.
if (Test-Path -LiteralPath $LegacyConfigPath) {
    $settings = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $legacy = Get-Content -LiteralPath $LegacyConfigPath -Raw | ConvertFrom-Json
    $changed = $false
    foreach ($property in $legacy.PSObject.Properties) {
        $current = $settings.PSObject.Properties[$property.Name]
        $isEmpty = $current -and ($null -eq $current.Value -or
            ($current.Value -is [string] -and [string]::IsNullOrWhiteSpace($current.Value))
        )
        if ($isEmpty) {
            $current.Value = $property.Value
            $changed = $true
        }
    }
    if ($changed) {
        $json = $settings | ConvertTo-Json -Depth 12
        [IO.File]::WriteAllText($ConfigPath, $json + [Environment]::NewLine, (New-Object Text.UTF8Encoding($false)))
        Write-Host "Copied saved values into setup.json; the old config was left untouched."
    }
}

Write-Host ""
Write-Host "Installation complete. Edit your settings here:"
Write-Host "  $ConfigPath"
Write-Host "Then run start-server.bat."
