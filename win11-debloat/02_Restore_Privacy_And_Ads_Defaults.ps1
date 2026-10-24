<#
.SYNOPSIS
    Rollback for Stage 1: Restores Windows 11 Privacy, Telemetry, Search & Ads to Defaults.
.DESCRIPTION
    Reverts all registry policies, content delivery options, and scheduled tasks modified
    by 02_Apply_Privacy_And_Ads_Hardening.ps1 back to factory defaults.
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

Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host "  Rollback Stage 1: Restoring Privacy & Ads to Defaults   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host ""

function Remove-RegistryValueSafe {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Name
    )
    if (Test-Path $Path) {
        if (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue
            Write-Host "  [+] Removed policy override: $Path\$Name" -ForegroundColor Green
        }
    }
}

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
    Write-Host "  [+] Restored default: $Path\$Name = $Value" -ForegroundColor Green
}

# 1. Telemetry & Diagnostic Data
Write-Host "[1/7] Restoring Telemetry Policies..." -ForegroundColor Cyan
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry"
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "MaxTelemetryAllowed"
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable"
Remove-RegistryValueSafe -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod"

# 2. Advertising ID & Activity Feed
Write-Host "`n[2/7] Restoring Advertising ID & Activity History..." -ForegroundColor Cyan
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy"
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed"
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities"
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities"

# 3. Inking & Typing Personalization
Write-Host "`n[3/7] Restoring Inking & Typing Defaults..." -ForegroundColor Cyan
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Value 0
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 0
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 1

# 4. Windows AI & Recall Policies
Write-Host "`n[4/7] Restoring Windows AI & Recall Policies..." -ForegroundColor Cyan
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis"
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableRecall"

# 5. Search & Bing Integration
Write-Host "`n[5/7] Restoring Search & Bing Defaults..." -ForegroundColor Cyan
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 1
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 1
Remove-RegistryValueSafe -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions"
Set-RegistryValueSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Value 1

# 6. Consumer Promos & Ads
Write-Host "`n[6/7] Restoring Content Delivery Manager Defaults..." -ForegroundColor Cyan
$cdmPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-RegistryValueSafe -Path $cdmPath -Name "SilentInstalledAppsEnabled" -Value 1
Set-RegistryValueSafe -Path $cdmPath -Name "SystemPaneSuggestionsEnabled" -Value 1
Set-RegistryValueSafe -Path $cdmPath -Name "RotatingLockScreenOverlayEnabled" -Value 1
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-338388Enabled" -Value 1
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-338389Enabled" -Value 1
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-310093Enabled" -Value 1
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-353694Enabled" -Value 1
Set-RegistryValueSafe -Path $cdmPath -Name "SubscribedContent-353696Enabled" -Value 1

$cloudPath = "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
Remove-RegistryValueSafe -Path $cloudPath -Name "DisableWindowsConsumerFeatures"
Remove-RegistryValueSafe -Path $cloudPath -Name "DisableTailoredExperiencesWithDiagnosticData"

Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode"

# 7. Scheduled Tasks
Write-Host "`n[7/7] Re-enabling Telemetry Scheduled Tasks..." -ForegroundColor Cyan
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
            Enable-ScheduledTask -InputObject $taskObj -ErrorAction SilentlyContinue | Out-Null
            Write-Host "  [+] Re-enabled task: $task" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [-] Could not enable task: $task" -ForegroundColor Gray
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  Stage 1 Defaults Restored Successfully!                 " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
