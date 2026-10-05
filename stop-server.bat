@echo off
rem -------------------------------------------------
rem Stop Local Coding Agent server and tunnel
rem -------------------------------------------------

rem Change directory to the project root (the folder containing this .bat)
pushd "%~dp0"

rem Execute the stop command
node scripts\local-coding-agent.mjs stop

rem Also stop an older/untracked tunnel-client that owns the tunnel health port.
rem Only a process named tunnel-client.exe is eligible for termination.
powershell.exe -NoProfile -Command "$conns=Get-NetTCPConnection -LocalPort 8788 -State Listen -ErrorAction SilentlyContinue; foreach($c in $conns){$p=Get-CimInstance Win32_Process -Filter ('ProcessId = ' + $c.OwningProcess) -ErrorAction SilentlyContinue; if($p -and $p.Name -ieq 'tunnel-client.exe'){Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue; Write-Host ('Stopped tunnel-client PID ' + $c.OwningProcess)}}"

rem Inform the user
echo.
echo Local Coding Agent server and tunnel have been stopped.

rem Keep the window open so the user can see the message
pause

popd
