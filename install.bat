@echo off
setlocal
cd /d "%~dp0"

title Local Coding Agent - Apply Settings / Install

echo ========================================================
echo   Local Coding Agent - Apply Settings (install.ps1)
echo ========================================================
echo.
echo Dang ap dung cau hinh tu install.ps1 va khoi dong lai server...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" (
    echo [ERROR] Da co loi xay ra khi chay install.ps1 (Ma loi: %EXIT_CODE%).
) else (
    echo [OK] Cau hinh da duoc luu va cap nhat thanh cong!
)

echo.
echo Nhan phim bat ky de thoat...
pause >nul
exit /b %EXIT_CODE%
