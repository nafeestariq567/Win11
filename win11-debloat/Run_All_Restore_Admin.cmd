@echo off
setlocal
title Windows 11 Master Rollback

echo ==========================================================
echo    Windows 11 Master Rollback Suite
echo ==========================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [i] Administrator privileges required. Elevating via UAC...
    powershell.exe -Command "Start-Process cmd -ArgumentList '/c \"\"%~dpnx0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo [*] Executing master rollback PowerShell suite...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Run_All_Restore.ps1"

echo.
echo ==========================================================
echo Rollback completed! Press any key to exit this window.
echo ==========================================================
pause >nul
