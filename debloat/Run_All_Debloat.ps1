<#
.SYNOPSIS
    Master Automated Debloat Runner for Windows 11 (Acer Predator / Developer Edition).
.DESCRIPTION
    Executes the complete, personalized Windows 11 debloat sequence in order:
      Step 1: Baseline Restore Point & Registry Export
      Step 2: Privacy, Telemetry, Inking, Bing & Ads Hardening
      Step 3: Curated Bloatware Removal (13 confirmed packages)
      Step 4: Explorer, Taskbar, Edge, Sleep Power & Services Optimization
.NOTES
    Fully automated for fresh Windows 11 reinstalls.
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
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Windows 11 Master Debloat Suite (Developer Edition)    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Target OS: Windows 11 Pro 64-bit" -ForegroundColor Gray
Write-Host " Profile: Developer / Acer Predator Laptop" -ForegroundColor Gray
Write-Host ""

# Step 1: Baseline
Write-Host ">>> STEP 1: Creating Safety Baseline & Restore Point..." -ForegroundColor Cyan
& "$scriptDir\01_Create_Safety_Baseline.ps1"

# Step 2: Privacy & Ads
Write-Host "`n>>> STEP 2: Applying Privacy, Telemetry & Ads Hardening..." -ForegroundColor Cyan
& "$scriptDir\02_Apply_Privacy_And_Ads_Hardening.ps1"

# Step 3: Bloatware Removal
Write-Host "`n>>> STEP 3: Removing Curated Bloatware Packages..." -ForegroundColor Cyan
& "$scriptDir\03_Remove_Bloatware_Apps.ps1"

# Step 4: UI, Taskbar, Edge & Services
Write-Host "`n>>> STEP 4: Applying Explorer, Taskbar, Power & Services Tweaks..." -ForegroundColor Cyan
& "$scriptDir\04_Apply_UI_And_Services.ps1"

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   Master Debloat Completed Successfully!                 " -ForegroundColor Green
Write-Host "   Your system is now clean, private, fast, and optimized." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
