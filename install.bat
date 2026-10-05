@echo off
setlocal
cd /d "%~dp0"

title Local Coding Agent - Install

echo ========================================================
echo   Local Coding Agent - Install (install.ps1)
echo ========================================================
echo.
echo Dang chuan bi setup.json va cai dependencies...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" (
    echo [ERROR] Da co loi xay ra khi chay install.ps1 (Ma loi: %EXIT_CODE%).
) else (
    echo [OK] Cai dat xong. Hay sua setup.json roi chay start-server.bat.
)

echo.
echo Nhan phim bat ky de thoat...
pause >nul
exit /b %EXIT_CODE%
