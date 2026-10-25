@echo off
title Reset App Locker Master Password
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Reset-Password.ps1"
pause
