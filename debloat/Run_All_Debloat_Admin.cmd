@echo off
setlocal
title Windows 11 Master Debloat - 1-Click Suite

echo ==========================================================
echo    Windows 11 Master Debloat Suite (Developer Edition)
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
echo [*] Executing master debloat PowerShell suite...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Run_All_Debloat.ps1"

echo.
echo ==========================================================
echo All steps completed! Press any key to exit this window.
echo ==========================================================
pause >nul
