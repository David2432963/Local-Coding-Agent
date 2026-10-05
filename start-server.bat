@echo off
setlocal

rem ============================================================
rem  Local Coding Agent - one-click launcher
rem  All configurable settings are grouped here at the top.
rem ============================================================

rem --- Workspace --------------------------------------------------
rem  AGENT_ROOT:        Main workspace folder ChatGPT can read/write
rem  AGENT_EXTRA_ROOTS: Extra roots separated by semicolons (optional)
set "AGENT_ROOT=D:\Tools\local-coding-agent"
set "AGENT_WORKSPACE=%AGENT_ROOT%"
set "AGENT_EXTRA_ROOTS="

rem --- Mode & Policy ----------------------------------------------
rem  AGENT_MODE:         safe | full
rem  AGENT_POLICY:       balanced | strict | full
rem  AGENT_ALLOW_DANGEROUS: 1 to allow destructive commands (use with caution)
set "AGENT_MODE=full"
set "AGENT_POLICY=balanced"
set "AGENT_ALLOW_DANGEROUS=0"

rem --- Ports ------------------------------------------------------
rem  PORT:           MCP server port (default 8787)
rem  DASHBOARD_PORT: Local dashboard port (default 8790)
rem  NOTE: Do NOT use 8788 — the tunnel client reserves it.
set "PORT=8787"
set "DASHBOARD_PORT=8790"

rem --- Security ---------------------------------------------------
rem  MCP_AUTH_TOKEN: Optional bearer token for /mcp endpoint.
rem                  Leave empty when using the OpenAI tunnel (recommended).
set "MCP_AUTH_TOKEN="

rem --- Optional Features ------------------------------------------
rem  AGENT_V5_PREVIEW:          1=enabled (default), 0=disable v5 features
rem  AGENT_BROWSER_PREVIEW:     1=enable Chrome Companion, 0=disable (default)
rem  AGENT_ALLOW_SYSTEM_SHUTDOWN: 1=allow shutdown tool, 0=disable (default)
set "AGENT_V5_PREVIEW=1"
set "AGENT_BROWSER_PREVIEW=0"
set "AGENT_ALLOW_SYSTEM_SHUTDOWN=0"

rem ============================================================
rem  Internal — do not edit below this line
rem ============================================================

if not exist "%AGENT_ROOT%" (
  echo ERROR: Workspace not found:
  echo        %AGENT_ROOT%
  pause
  exit /b 1
)

set "REPO_ROOT=%~dp0"
if "%REPO_ROOT:~-1%"=="\" set "REPO_ROOT=%REPO_ROOT:~0,-1%"

if not exist "%REPO_ROOT%\server\package.json" (
  echo ERROR: server\package.json not found under:
  echo        %REPO_ROOT%
  pause
  exit /b 1
)

if not exist "%REPO_ROOT%\tools\tunnel-client.exe" (
  echo ERROR: tools\tunnel-client.exe not found.
  echo Obtain the proprietary tunnel client and place it there first.
  pause
  exit /b 1
)

echo Workspace: %AGENT_WORKSPACE%
echo Mode:      %AGENT_MODE%  Policy: %AGENT_POLICY%
echo Ports:     MCP=%PORT%  Dashboard=%DASHBOARD_PORT%
echo Checking for an already-running tunnel...
powershell.exe -NoProfile -Command "try { $r=Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:8788/healthz' -TimeoutSec 2; if ($r.StatusCode -eq 200 -and $r.Content -match 'live') { exit 0 } else { exit 1 } } catch { exit 1 }"
if "%ERRORLEVEL%"=="0" (
  echo Existing tunnel is healthy; reusing it.
  node "%REPO_ROOT%\scripts\local-coding-agent.mjs" start --background --no-tunnel --workspace "%AGENT_WORKSPACE%" --mode %AGENT_MODE%
) else (
  echo Starting MCP server and tunnel from the saved CLI configuration...
  node "%REPO_ROOT%\scripts\local-coding-agent.mjs" start --background --workspace "%AGENT_WORKSPACE%" --mode %AGENT_MODE%
)

if not "%ERRORLEVEL%"=="0" (
  echo.
  echo ERROR: Could not start the MCP server and tunnel.
  echo Run install.ps1 once to save the Runtime API key in the local CLI config.
  pause
  exit /b 1
)

timeout /t 3 /nobreak >nul
start "" "http://127.0.0.1:%DASHBOARD_PORT%/ui"

echo Dashboard opened: http://127.0.0.1:%DASHBOARD_PORT%/ui
echo The server and tunnel are running in the background.
exit /b 0
