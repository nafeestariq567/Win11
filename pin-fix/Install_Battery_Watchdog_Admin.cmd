@echo off
setlocal
title Install Win11 Battery Sleep Watchdog

echo ==========================================================
echo    Install Win11 Battery Sleep Watchdog (Safety Suite)
echo ==========================================================
echo.

:: Check for Administrator elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [i] Administrator privileges required. Elevating via UAC...
    powershell.exe -Command "Start-Process cmd -ArgumentList '/c \"\"%~dpnx0\"\"' -Verb RunAs"
    exit /b
)

:: Running elevated
cd /d "%~dp0"
echo [*] Installing Watchdog Suite...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Install_Battery_Watchdog.ps1"

echo.
echo ==========================================================
echo Process finished. Press any key to exit this window.
echo ==========================================================
pause >nul
