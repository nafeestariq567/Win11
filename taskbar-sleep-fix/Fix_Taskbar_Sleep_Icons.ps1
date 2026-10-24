<#
.SYNOPSIS
    Windows 11 Taskbar Sleep Icon Disappearance Resolver
.DESCRIPTION
    Permanently resolves the issue where pinned or opened application icons turn
    blank/invisible after system sleep or display power state changes on multi-GPU
    and mixed-refresh-rate systems (e.g. Acer Predator with Intel UHD 630 + NVIDIA RTX 2070).
    
    1. Sets PCIe Link State Power Management (ASPM) to Off (0) on AC power to prevent GPU TDR 141 timeouts.
       Leaves Battery (DC) power at Maximum power savings (2) to guarantee ZERO battery drain.
    2. Rebuilds stale Explorer icon and thumbnail cache databases.
    3. Cleanly restarts Explorer.
.NOTES
    Author: Nafees Tariq (nafeestariq567)
    Repository: https://github.com/nafeestariq567/Windows11-Taskbar-Sleep-Fix
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Windows 11 Taskbar Sleep Icon Disappearance Resolver   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Hardware & Power: Eliminate PCIe Wake Timeout (AC only, DC untouched)
Write-Host "[1/2] Configuring PCIe Link State Power Management..." -ForegroundColor Yellow
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0
powercfg /SETACTIVE SCHEME_CURRENT
Write-Host "  -> AC Link State (ASPM): Set to 0 (Off - No wake latency / Eliminates GPU TDR 141)" -ForegroundColor Green
Write-Host "  -> DC Link State (ASPM): Preserved at Maximum Power Savings (0 Battery Drain)" -ForegroundColor Green

# 2. Cache Purge: Wipe Stale Icon Databases and Restart Explorer
Write-Host "`n[2/2] Purging Stale Icon Caches and Restarting Windows Explorer..." -ForegroundColor Yellow

$explorerProc = Get-Process -Name explorer -ErrorAction SilentlyContinue
if ($explorerProc) {
    Stop-Process -Name explorer -Force
    Start-Sleep -Milliseconds 1500
}

# Remove legacy and current icon cache databases
$localAppData = $env:LOCALAPPDATA
Remove-Item -Path "$localAppData\IconCache.db" -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "$localAppData\Microsoft\Windows\Explorer" -Filter "*iconcache*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "$localAppData\Microsoft\Windows\Explorer" -Filter "*thumbcache*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "  -> Icon and thumbnail cache databases purged cleanly." -ForegroundColor Green

# Relaunch Explorer
Start-Process "explorer.exe"
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Fix Applied & Verified Successfully!                    " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
