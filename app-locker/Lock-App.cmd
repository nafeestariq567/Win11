@echo off
title Lock Desktop App
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Lock-App.ps1"
pause
