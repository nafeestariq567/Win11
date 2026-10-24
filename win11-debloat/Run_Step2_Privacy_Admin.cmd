@echo off
setlocal
title Windows 11 Debloat - Stage 1 Privacy & Ads Hardening

echo ==========================================================
echo    Stage 1: Privacy, Telemetry, Bing Search & Ads
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
echo [*] Running Stage 1 PowerShell script...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\02_Apply_Privacy_And_Ads_Hardening.ps1"

echo.
echo ==========================================================
echo Process finished. Press any key to exit this window.
echo ==========================================================
pause >nul
