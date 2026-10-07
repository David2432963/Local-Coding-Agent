@echo off
setlocal
cd /d "%~dp0"

title Local Coding Agent - Start

set "REPO_ROOT=%~dp0"
set "CLI=%REPO_ROOT%scripts\local-coding-agent.mjs"
set "LCA_CONFIG_PATH=%REPO_ROOT%setup.json"

if not exist "%CLI%" (
  echo ERROR: Local Coding Agent launcher was not found:
  echo        %CLI%
  pause
  exit /b 1
)

if not exist "%LCA_CONFIG_PATH%" (
  echo ERROR: Project setup file was not found:
  echo        %LCA_CONFIG_PATH%
  echo Restore setup.json from the repository; install.bat does not create it.
  pause
  exit /b 1
)

where node.exe >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js was not found on PATH. Install Node.js 18 or newer.
  pause
  exit /b 1
)

echo Starting with setup.json...
powershell.exe -NoProfile -Command "$c=Get-Content -Raw -LiteralPath $env:LCA_CONFIG_PATH | ConvertFrom-Json; $p=$c.tunnelHealthPort; if(-not $p){$p='8788'}; try{$r=Invoke-WebRequest -UseBasicParsing -Uri ('http://127.0.0.1:'+$p+'/healthz') -TimeoutSec 2; if($r.StatusCode -eq 200 -and $r.Content -match 'live'){exit 0}}catch{}; exit 1"
if "%ERRORLEVEL%"=="0" (
  echo Existing tunnel is healthy; reusing it.
  node "%CLI%" start --background --no-tunnel
) else (
  node "%CLI%" start --background
)

if errorlevel 1 (
  echo.
  echo ERROR: Could not start Local Coding Agent.
  echo Run install.bat to install and configure it, then try again.
  pause
  exit /b 1
)

node "%CLI%" open
if errorlevel 1 (
  echo Server started, but the dashboard could not be opened automatically.
  echo Run: node scripts\local-coding-agent.mjs status
)

echo.
echo Local Coding Agent is running with the saved configuration.
exit /b 0
