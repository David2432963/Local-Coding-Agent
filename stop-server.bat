@echo off
setlocal
rem -------------------------------------------------
rem Stop Local Coding Agent server and tunnel
rem -------------------------------------------------

rem Change directory to the project root (the folder containing this .bat)
pushd "%~dp0"

set "LCA_CONFIG_PATH=%~dp0setup.json"

rem Execute the stop command
node "%~dp0scripts\local-coding-agent.mjs" stop

rem Also stop an older/untracked tunnel-client that owns the tunnel health port.
rem Only a process named tunnel-client.exe is eligible for termination.
powershell.exe -NoProfile -Command "$cfg=Get-Content -Raw -LiteralPath $env:LCA_CONFIG_PATH | ConvertFrom-Json; $port=$cfg.tunnelHealthPort; if(-not $port){$port=8788}; $conns=Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue; foreach($c in $conns){$p=Get-CimInstance Win32_Process -Filter ('ProcessId = ' + $c.OwningProcess) -ErrorAction SilentlyContinue; if($p -and $p.Name -ieq 'tunnel-client.exe'){Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue; Write-Host ('Stopped tunnel-client PID ' + $c.OwningProcess)}}"

rem Inform the user
echo.
echo Local Coding Agent server and tunnel have been stopped.

rem Keep the window open so the user can see the message
pause

popd
