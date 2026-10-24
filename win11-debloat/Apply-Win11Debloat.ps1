<#
.SYNOPSIS
    Standalone 1-Line Remote & Local Windows 11 Debloat Suite (Developer Edition).
.DESCRIPTION
    Full debloating, optimization, and privacy hardening script for Windows 11 Pro 64-bit.
    Tailored for: Software Engineers / Power Users on Acer Predator Laptops.
    Compatible with:
      irm https://raw.githubusercontent.com/nafeestariq567/Win11Debloat/main/Apply-Win11Debloat.ps1 | iex
.NOTES
    Author: nafeestariq567
    Repository: https://github.com/nafeestariq567/Win11Debloat
#>

[CmdletBinding()]
param()

# Ensure Administrator Privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "[*] Please re-run PowerShell as Administrator, then execute the command again." -ForegroundColor Yellow
    return
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Windows 11 Master Debloat Suite (Developer Edition)    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Target OS: Windows 11 Pro 64-bit" -ForegroundColor Gray
Write-Host " Profile: Developer / Acer Predator Laptop" -ForegroundColor Gray
Write-Host " Source: https://github.com/nafeestariq567/Win11Debloat" -ForegroundColor Gray
Write-Host ""

function Set-RegistryValueSafe {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)]$Value,
        [Parameter(Mandatory=$false)][string]$Type = "DWord"
    )
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
        Write-Host "  [+] Set: $Path\$Name = $Value" -ForegroundColor Green
    } catch {
        $regPath = $Path.Replace("HKCU:\", "HKCU\").Replace("HKLM:\", "HKLM\")
        $regType = if ($Type -eq "DWord") { "REG_DWORD" } else { "REG_SZ" }
        $null = & reg add "$regPath" /v "$Name" /t "$regType" /d "$Value" /f 2>$null
        Write-Host "  [+] Set (via reg): $Path\$Name = $Value" -ForegroundColor Green
    }
}

# ========================================================
# STEP 1: SAFETY BASELINE & SYSTEM RESTORE POINT
# ========================================================
Write-Host ">>> STEP 1: Creating Safety Baseline & Restore Point..." -ForegroundColor Cyan

$backupDir = "C:\Debloat Windows 11\Backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

try {
    $srKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
    if (Test-Path $srKey) {
        Set-ItemProperty -Path $srKey -Name "SystemRestorePointCreationFrequency" -Value 0 -Type DWord -Force
        Write-Host "  [+] Unthrottled System Restore frequency" -ForegroundColor Green
    }
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    $rpName = "Pre-Debloat Baseline (Clean State)"
    Write-Host "  [*] Creating System Restore Point: '$rpName'..." -ForegroundColor Yellow
    Checkpoint-Computer -Description $rpName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "  [SUCCESS] Restore Point created successfully!" -ForegroundColor Green
} catch {
    Write-Warning "  [-] Could not create Restore Point: $_"
}

# Quick registry baseline export
$regTargets = @(
    @{ Path = "HKLM\SOFTWARE\Policies\Microsoft\Windows"; File = "HKLM_Policies_Windows_Baseline.reg" },
    @{ Path = "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; File = "HKCU_ContentDeliveryManager_Baseline.reg" },
    @{ Path = "HKCU\Software\Microsoft\Windows\CurrentVersion\Search"; File = "HKCU_Search_Baseline.reg" },
    @{ Path = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; File = "HKCU_Explorer_Advanced_Baseline.reg" }
)
foreach ($target in $regTargets) {
    $outFile = Join-Path $backupDir $target.File
    $null = & reg export "$($target.Path)" "$outFile" /y 2>$null
}
Write-Host "  [+] Baseline registry exports saved to: $backupDir" -ForegroundColor Green

# ========================================================
# STEP 2: PRIVACY, TELEMETRY, INKING, BING & ADS HARDENING
# ========================================================
Write-Host "`n>>> STEP 2: Applying Privacy, Telemetry & Ads Hardening..." -ForegroundColor Cyan

# Telemetry
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "MaxTelemetryAllowed" -Value 1
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Value 0
Set-RegistryValueSafe -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0

# Advertising ID & Activity History
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0

# Inking & Typing Telemetry
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Value 1
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 1
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 0
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0

# Windows AI & Recall (Copilot app kept accessible)
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Value 1
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableRecall" -Value 1

# Bing in Start Search & Search Highlights
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0
Set-RegistryValueSafe -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Value 0

# Content Delivery Manager & Consumer Promos
$cdmPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-RegistryValueSafe -Path $cdmPath -Name "SilentInstalledAppsEnabled" -Value 0
Set-RegistryValueSafe -Path $cdmPath -Name "SystemPaneSuggestionsEnabled" -Value 0
Set-RegistryValueSafe -Path $cdmPath -Name "RotatingLockScreenOverlayEnabled" -Value 0
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-338388Enabled" -Value 0
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-338389Enabled" -Value 0
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-310093Enabled" -Value 0
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-353694Enabled" -Value 0
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-353696Enabled" -Value 0

$cloudPath = "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
Set-RegistryValueSafe -Path $cloudPath -Name "DisableWindowsConsumerFeatures" -Value 1
Set-RegistryValueSafe -Path $cloudPath -Name "DisableTailoredExperiencesWithDiagnosticData" -Value 1

# Delivery Optimization P2P Sharing Off
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0

# Purge leftover OneDrive startup key
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
if (Get-ItemProperty -Path $runKey -Name "OneDriveSetup" -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path $runKey -Name "OneDriveSetup" -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Purged leftover OneDriveSetup startup key" -ForegroundColor Green
}

# Telemetry Scheduled Tasks
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Autochk\Proxy"
)
foreach ($task in $tasks) {
    try {
        $taskObj = Get-ScheduledTask -TaskName ($task.Split('\')[-1]) -TaskPath ($task.Substring(0, $task.LastIndexOf('\') + 1)) -ErrorAction SilentlyContinue
        if ($taskObj) {
            Disable-ScheduledTask -InputObject $taskObj -ErrorAction SilentlyContinue | Out-Null
            Write-Host "  [+] Disabled task: $task" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [-] Could not disable task: $task" -ForegroundColor Gray
    }
}

# ========================================================
# STEP 3: CURATED BLOATWARE REMOVAL (13 PACKAGES)
# ========================================================
Write-Host "`n>>> STEP 3: Removing Curated Bloatware Packages..." -ForegroundColor Cyan

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

foreach ($pkg in $bloatwarePackages) {
    $installed = Get-AppxPackage -Name $pkg -ErrorAction SilentlyContinue
    if ($installed) {
        $installed | Remove-AppxPackage -ErrorAction SilentlyContinue
        Write-Host "  [+] Removed app: $pkg" -ForegroundColor Green
    }
    $prov = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $pkg }
    if ($prov) {
        Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction SilentlyContinue | Out-Null
        Write-Host "  [+] Deprovisioned: $pkg" -ForegroundColor Green
    }
}

# ========================================================
# STEP 4: UI, EXPLORER, POWER & SERVICES
# ========================================================
Write-Host "`n>>> STEP 4: Applying Explorer, Taskbar, Power & Services Tweaks..." -ForegroundColor Cyan

$advExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-RegistryValueSafe -Path $advExplorer -Name "HideFileExt" -Value 0
Set-RegistryValueSafe -Path $advExplorer -Name "Hidden" -Value 1
Set-RegistryValueSafe -Path $advExplorer -Name "NoNetCrawling" -Value 1

Set-RegistryValueSafe -Path "$advExplorer\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -Value 1
Set-RegistryValueSafe -Path $advExplorer -Name "TaskbarMn" -Value 0
Set-RegistryValueSafe -Path $advExplorer -Name "TaskbarDa" -Value 0

# Remove Widgets WebExperience
$webExp = Get-AppxPackage -Name "*WebExperience*" -ErrorAction SilentlyContinue
if ($webExp) { $webExp | Remove-AppxPackage -ErrorAction SilentlyContinue }
$webExpProv = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*WebExperience*" }
if ($webExpProv) { Remove-AppxProvisionedPackage -Online -PackageName $webExpProv.PackageName -ErrorAction SilentlyContinue | Out-Null }
Write-Host "  [+] Removed & deprovisioned Taskbar Widgets WebExperience" -ForegroundColor Green

# Snappy UI Delay
Set-RegistryValueSafe -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "150" -Type "String"

# Edge Background Boost Off
$edgePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
Set-RegistryValueSafe -Path $edgePolicy -Name "StartupBoostEnabled" -Value 0
Set-RegistryValueSafe -Path $edgePolicy -Name "BackgroundModeEnabled" -Value 0

# Power: Disable Sleep Wake Timers
try {
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 0 | Out-Null
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 0 | Out-Null
    powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
    Write-Host "  [+] Disabled Sleep Wake Timers (Backpack overheat protection)" -ForegroundColor Green
} catch {
    Write-Host "  [-] Could not set powercfg wake timers: $_" -ForegroundColor Gray
}

# Services: DiagTrack & dmwappushservice to Manual
$services = @("DiagTrack", "dmwappushservice")
foreach ($svc in $services) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
        Write-Host "  [+] Stopped and set to Manual: $svc" -ForegroundColor Green
    }
}

# Restart Windows Explorer to apply UI tweaks
Write-Host "`n[*] Restarting Windows Explorer..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   Master Debloat Completed Successfully!                 " -ForegroundColor Green
Write-Host "   Your system is now clean, private, fast, and optimized." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
