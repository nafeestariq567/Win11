@echo off
setlocal
title Fix Windows Hello PIN Corruption

echo ==========================================================
echo       Fix Windows Hello PIN Corruption & Crash Resolver
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
echo [*] Running PIN repair script...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Fix_Windows_Hello_PIN.ps1"

echo.
echo ==========================================================
echo Process finished. Press any key to exit this window.
echo ==========================================================
pause >nul
