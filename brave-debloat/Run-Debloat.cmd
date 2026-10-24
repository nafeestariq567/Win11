@echo off
:: ==============================================================================
:: One-Click Brave & Brave Beta Debloat Launcher
:: Automatically requests Administrator privileges and runs Apply-BraveDebloat.ps1
:: ==============================================================================
setlocal EnableDelayedExpansion

:: Check for administrative rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Brave Debloat Launcher
cd /d "%~dp0"

echo Running Brave Debloat Script...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Apply-BraveDebloat.ps1"

echo.
pause
