<#
.SYNOPSIS
    Stage 1: Core Privacy, Telemetry, Bing Search & Ads Hardening for Windows 11.
.DESCRIPTION
    Applies enterprise Group Policies and user registry tweaks to minimize diagnostic telemetry,
    disable Bing web results in Start search, eliminate sponsored consumer apps, stop keystroke
    harvesting, and disable telemetry scheduled tasks while keeping Location and Copilot intact.
.NOTES
    Tailored for: Software Engineer / Acer Predator (Windows 11 Pro).
    Reversible via: 02_Restore_Privacy_And_Ads_Defaults.ps1
#>

[CmdletBinding()]
param()

function Test-IsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Auto-elevate if not running as Administrator
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
Write-Host "  Stage 1: Privacy, Telemetry, Bing Search & Ads Hardening" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

function Set-RegistryValueSafe {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)]$Value,
        [Parameter(Mandatory=$false)][string]$Type = "DWord"
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
    Write-Host "  [+] Set: $Path\$Name = $Value" -ForegroundColor Green
}

# 1. Telemetry & Diagnostic Data (Enterprise Policies)
Write-Host "[1/7] Hardening Diagnostic Data & Telemetry..." -ForegroundColor Yellow
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "MaxTelemetryAllowed" -Value 1
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Value 0
Set-RegistryValueSafe -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0

# 2. Advertising ID & Activity History
Write-Host "`n[2/7] Disabling Advertising ID & Activity Timeline..." -ForegroundColor Yellow
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0

# 3. Inking & Typing Personalization (Keystroke & Dictionary Harvesting)
Write-Host "`n[3/7] Disabling Inking & Typing Telemetry..." -ForegroundColor Yellow
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Value 1
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 1
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 0
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0

# 4. Windows AI & Recall Telemetry (Keeping Copilot App Available)
Write-Host "`n[4/7] Disabling Recall & AI Diagnostic Telemetry (Copilot kept accessible)..." -ForegroundColor Yellow
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Value 1
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableRecall" -Value 1

# 5. Bing Web Search in Start Menu & Search Highlights
Write-Host "`n[5/7] Disabling Bing in Start Menu & Search Highlights..." -ForegroundColor Yellow
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0
Set-RegistryValueSafe -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Value 0

# 6. Consumer Promoted Apps, Suggestions & Lock Screen Ads
Write-Host "`n[6/7] Disabling Consumer Promos, Suggested Apps & Ads..." -ForegroundColor Yellow
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

# Delivery Optimization P2P Sharing
Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0

# Purge leftover OneDrive startup registry trigger if present
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
if (Get-ItemProperty -Path $runKey -Name "OneDriveSetup" -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path $runKey -Name "OneDriveSetup" -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Purged leftover OneDriveSetup auto-install key from HKCU Run" -ForegroundColor Green
}

# 7. Telemetry Scheduled Tasks
Write-Host "`n[7/7] Disabling Telemetry Scheduled Tasks (Local Event Viewer logs untouched)..." -ForegroundColor Yellow
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
        } else {
            Write-Host "  [i] Task not found / already absent: $task" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  [-] Could not disable task: $task ($($_))" -ForegroundColor Gray
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "  Stage 1 Applied Successfully! Privacy & Ads Hardened.   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
