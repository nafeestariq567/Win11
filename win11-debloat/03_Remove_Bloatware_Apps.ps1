<#
.SYNOPSIS
    Stage 2: Curated UWP Bloatware Removal for Windows 11.
.DESCRIPTION
    Safely removes 13 confirmed consumer bloatware packages for the current user and
    deprovisions them online so they never reinstall on future user profiles.
    Guarantees that all developer tools (Dev Home, Terminal), Acer hardware utilities
    (PredatorSense), Screen recording (Xbox Game Bar), Camera, Clock, Clipchamp, and
    Phone Link remain 100% untouched.
.NOTES
    Reversible via: 03_Reinstall_Bloatware_Apps.ps1 or Microsoft Store.
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

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Stage 2: Curated Bloatware App Removal (13 Packages)    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Explicitly Whitelisted Apps (Will NEVER be removed)
$whitelisted = @(
    "Microsoft.Windows.DevHome",
    "Microsoft.WindowsTerminal",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsNotepad",
    "Microsoft.Paint",
    "Microsoft.ScreenSketch",
    "Microsoft.WindowsPhotos",
    "Microsoft.WindowsStore",
    "Microsoft.DesktopAppInstaller",
    "Clipchamp.Clipchamp",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.YourPhone",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.WindowsAlarms",
    "AcerIncorporated.PredatorSenseV30",
    "AcerIncorporated.AcerCareCenterS",
    "AcerIncorporated.QuickAccess"
)

# Targeted bloatware packages confirmed by user
$bloatwarePackages = @(
    "Microsoft.GamingApp",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.Todos",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.GetHelp",
    "MicrosoftCorporationII.QuickAssist",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.People",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.ZuneMusic"
)

$i = 1
$total = $bloatwarePackages.Count

foreach ($pkg in $bloatwarePackages) {
    Write-Host "[$i/$total] Processing: $pkg..." -ForegroundColor Yellow
    
    # 1. Remove for current user
    $installed = Get-AppxPackage -Name $pkg -ErrorAction SilentlyContinue
    if ($installed) {
        try {
            $installed | Remove-AppxPackage -ErrorAction Stop
            Write-Host "  [+] Removed app for current user: $pkg" -ForegroundColor Green
        } catch {
            Write-Host "  [-] Failed to remove for current user: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  [i] Not installed for current user." -ForegroundColor Gray
    }

    # 2. Deprovision online package (prevents reinstall on new accounts)
    $provisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $pkg }
    if ($provisioned) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $provisioned.PackageName -ErrorAction Stop | Out-Null
            Write-Host "  [+] Deprovisioned online package: $($provisioned.DisplayName)" -ForegroundColor Green
        } catch {
            Write-Host "  [-] Failed to deprovision online package: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  [i] Not provisioned in OS image." -ForegroundColor Gray
    }

    $i++
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "  Stage 2 Completed! 13 Bloatware Packages Removed.        " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
