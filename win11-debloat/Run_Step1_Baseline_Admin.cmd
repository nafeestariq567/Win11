@echo off
setlocal
title Windows 11 Debloat - Step 1 Safety Baseline

echo ==========================================================
echo    Windows 11 Debloat: Step 1 Safety Baseline Runner
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
echo [*] Running elevated PowerShell script...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\01_Create_Safety_Baseline.ps1"

echo.
echo ==========================================================
echo Process finished. Press any key to exit this window.
echo ==========================================================
pause >nul
