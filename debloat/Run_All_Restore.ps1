<#
.SYNOPSIS
    Master Automated Rollback Runner for Windows 11.
.DESCRIPTION
    Restores all privacy policies, content delivery options, UI tweaks, power settings,
    and diagnostic services back to Microsoft defaults.
#>

[CmdletBinding()]
param()

function Test-IsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "[*] Requesting Administrator privileges..." -ForegroundColor Yellow
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    try {
        $proc = Start-Process powershell -ArgumentList $argList -Verb RunAs -PassThru -Wait
        exit $proc.ExitCode
    } catch {
        Write-Error "[-] Failed to elevate: $_"
        exit 1
    }
}

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = "C:\Debloat Windows 11" }

Clear-Host
Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host "   Windows 11 Master Rollback Suite                       " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host ""

Write-Host ">>> Restoring Privacy & Ads Defaults..." -ForegroundColor Cyan
& "$scriptDir\02_Restore_Privacy_And_Ads_Defaults.ps1"

Write-Host "`n>>> Restoring UI, Taskbar, Edge & Services Defaults..." -ForegroundColor Cyan
& "$scriptDir\04_Restore_UI_And_Services.ps1"

Write-Host "`n[i] Note: To reinstall removed apps, run 03_Reinstall_Bloatware_Apps.ps1" -ForegroundColor Yellow

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   All System Settings Successfully Restored to Default!  " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
