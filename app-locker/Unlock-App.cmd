@echo off
title Unlock Desktop App
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Unlock-App.ps1"
pause
