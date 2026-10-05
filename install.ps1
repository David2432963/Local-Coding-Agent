# Local Coding Agent
# Copyright (c) 2026 Long Nguyen
# SPDX-License-Identifier: AGPL-3.0-or-later

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# One-file launcher for Windows.
# Fill in the variables below, then run:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
#
# This script:
#   1) installs server deps if needed
#   2) writes the Local Coding Agent CLI config
#   3) starts server + tunnel using the repo's official launcher
#   4) prints status at the end
# ---------------------------------------------------------------------------

$RepoRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ServerDir = Join-Path $RepoRoot "server"
$Launcher  = Join-Path $RepoRoot "scripts\local-coding-agent.mjs"

# =========================
# EDIT THESE VALUES HERE
# =========================
$AgentWorkspace = $RepoRoot
$TunnelExe      = Join-Path $RepoRoot "tools\tunnel-client.exe"
$ProfileName    = "local-coding-agent"
$ProfileDir     = Join-Path $RepoRoot "tools\profiles"
$AgentMode      = "full"
$AgentPolicy    = "balanced"
$ExtraRoots     = ""
$AuthToken      = ""
$DashboardPort  = "8790"
$Port           = "8787"
$RuntimeApiKey  = ""
$TunnelId       = ""
$OrganizationId = ""
$RuntimeKeyEnv  = "CONTROL_PLANE_API_KEY"
# =========================
# END EDIT AREA
# =========================

function Require-Path([string]$PathValue, [string]$Label) {
    if (-not (Test-Path -LiteralPath $PathValue)) {
        throw "$Label not found: $PathValue"
    }
}

function Prompt-Secret([string]$Name) {
    $secureKey = Read-Host $Name -AsSecureString
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
    )
}

$NodeCmd = (Get-Command node.exe -ErrorAction Stop).Path

if (-not $AgentWorkspace) {
    $AgentWorkspace = $RepoRoot
}

Require-Path $AgentWorkspace "Workspace folder"
Require-Path $ServerDir "Server directory"
Require-Path $Launcher "Launcher"
Require-Path $TunnelExe "Tunnel client"

if (-not $TunnelId) {
    $TunnelId = Read-Host "OpenAI Tunnel ID"
}
if (-not $OrganizationId) {
    $OrganizationId = Read-Host "OpenAI Organization ID (optional)"
}

if (-not (Test-Path -LiteralPath (Join-Path $ServerDir "node_modules"))) {
    Write-Host "Installing server dependencies..."
    Push-Location $ServerDir
    try {
        & npm.cmd install --no-fund --no-audit
    }
    finally {
        Pop-Location
    }
}

$ConfigPath = Join-Path $env:APPDATA "LocalCodingAgent\cli-config.json"
$ConfigDir = Split-Path -Parent $ConfigPath
New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null

$config = [ordered]@{
    node = $NodeCmd
    workspace = [IO.Path]::GetFullPath($AgentWorkspace)
    extraRoots = $ExtraRoots
    mode = $AgentMode
    policy = $AgentPolicy
    port = $Port
    dashboardPort = $DashboardPort
    authToken = $AuthToken
    tunnelBin = $TunnelExe
    profile = $ProfileName
    profileDir = $ProfileDir
    tunnelId = $TunnelId
    organizationId = $OrganizationId
    runtimeKeyEnv = $RuntimeKeyEnv
    tunnelHealthPort = "8788"
    openWebUi = $true
    noTunnel = $false
}

$configJson = $config | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($ConfigPath, $configJson + [Environment]::NewLine, (New-Object Text.UTF8Encoding($false)))

Write-Host "Config written: $ConfigPath"
Write-Host "Workspace:      $($config.workspace)"
Write-Host "Organization:   $OrganizationId"
Write-Host "Tunnel ID:      $TunnelId"
Write-Host ""

if (-not $RuntimeApiKey) {
    Write-Host "Enter your Runtime API key to start the tunnel."
    $RuntimeApiKey = Prompt-Secret $RuntimeKeyEnv
}
if (-not $RuntimeApiKey) {
    throw "Runtime API key is required. Fill in `$RuntimeApiKey at the top of install.ps1 or enter it when prompted."
}
if (-not $TunnelId) {
    throw "Tunnel ID is required. Fill in `$TunnelId at the top of install.ps1."
}

# Persist the runtime key only in the user-local CLI config so the daily
# launcher can start without prompting. It is never written to this script.
$config.runtimeKey = $RuntimeApiKey
$configJson = $config | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($ConfigPath, $configJson + [Environment]::NewLine, (New-Object Text.UTF8Encoding($false)))

Set-Item -Path ("Env:{0}" -f $RuntimeKeyEnv) -Value $RuntimeApiKey
$env:CONTROL_PLANE_TUNNEL_ID = $TunnelId
$env:OPENAI_ORGANIZATION = $OrganizationId
# Keep the runtime settings available to future double-click launches.
# These values are stored in the current Windows user's environment, not in
# the repository files.
[Environment]::SetEnvironmentVariable($RuntimeKeyEnv, $RuntimeApiKey, "User")
[Environment]::SetEnvironmentVariable("CONTROL_PLANE_TUNNEL_ID", $TunnelId, "User")
[Environment]::SetEnvironmentVariable("OPENAI_ORGANIZATION", $OrganizationId, "User")
if ($AuthToken) {
    $env:MCP_AUTH_TOKEN = $AuthToken
}

Write-Host "Starting MCP server + tunnel in background..."
& $NodeCmd $Launcher start --background --workspace $AgentWorkspace --mode $AgentMode --policy $AgentPolicy --port $Port --dashboard-port $DashboardPort --tunnel-id $TunnelId --organization-id $OrganizationId --runtime-key-env $RuntimeKeyEnv --tunnel-bin $TunnelExe --profile $ProfileName --profile-dir $ProfileDir

Start-Sleep -Seconds 2
Write-Host ""
& $NodeCmd $Launcher status
