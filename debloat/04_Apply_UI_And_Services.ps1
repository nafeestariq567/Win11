<#
.SYNOPSIS
    Stage 3: Explorer, Taskbar, Edge Startup, Power & Services Optimization for Windows 11.
.DESCRIPTION
    Applies user-selected UI enhancements, disables Edge background processes, disables
    sleep wake timers, sets diagnostic telemetry services to Manual, and restarts Explorer.
.NOTES
    Reversible via: 04_Restore_UI_And_Services.ps1
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
Write-Host "  Stage 3: Explorer, Taskbar, Edge, Power & Services      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
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
        # Fallback to reg.exe if PowerShell property provider is locked
        $regPath = $Path.Replace("HKCU:\", "HKCU\").Replace("HKLM:\", "HKLM\")
        $regType = if ($Type -eq "DWord") { "REG_DWORD" } else { "REG_SZ" }
        $null = & reg add "$regPath" /v "$Name" /t "$regType" /d "$Value" /f 2>$null
        Write-Host "  [+] Set (via reg): $Path\$Name = $Value" -ForegroundColor Green
    }
}

# 1. File Explorer Enhancements
Write-Host "[1/6] Configuring File Explorer Settings..." -ForegroundColor Yellow
$advExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-RegistryValueSafe -Path $advExplorer -Name "HideFileExt" -Value 0                    # Show file extensions
Set-RegistryValueSafe -Path $advExplorer -Name "Hidden" -Value 1                         # Show hidden files & folders
Set-RegistryValueSafe -Path $advExplorer -Name "NoNetCrawling" -Value 1                  # Disable network auto-discovery lag

# 2. Taskbar Tweaks
Write-Host "`n[2/6] Configuring Taskbar Tweaks..." -ForegroundColor Yellow
Set-RegistryValueSafe -Path "$advExplorer\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -Value 1 # Enable End Task on right click
Set-RegistryValueSafe -Path $advExplorer -Name "TaskbarMn" -Value 0                      # Hide Chat / Teams icon
Set-RegistryValueSafe -Path $advExplorer -Name "TaskbarDa" -Value 0                      # Hide Widgets

# Remove WebExperience (Widgets background engine)
$webExp = Get-AppxPackage -Name "*WebExperience*" -ErrorAction SilentlyContinue
if ($webExp) {
    $webExp | Remove-AppxPackage -ErrorAction SilentlyContinue
    Write-Host "  [+] Removed Widgets WebExperience package" -ForegroundColor Green
}
$webExpProv = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*WebExperience*" }
if ($webExpProv) {
    Remove-AppxProvisionedPackage -Online -PackageName $webExpProv.PackageName -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  [+] Deprovisioned Widgets WebExperience from OS image" -ForegroundColor Green
}

# 3. UI Snappiness (MenuShowDelay)
Write-Host "`n[3/6] Setting MenuShowDelay to 150ms (Snappy Menus)..." -ForegroundColor Yellow
Set-RegistryValueSafe -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "150" -Type "String"

# 4. Microsoft Edge Background Processes & Startup Boost
Write-Host "`n[4/6] Disabling Edge Startup Boost & Background Extensions..." -ForegroundColor Yellow
$edgePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
Set-RegistryValueSafe -Path $edgePolicy -Name "StartupBoostEnabled" -Value 0
Set-RegistryValueSafe -Path $edgePolicy -Name "BackgroundModeEnabled" -Value 0

# 5. Laptop Sleep Wake-Timers (Backpack Overheat Protection)
Write-Host "`n[5/6] Disabling Sleep Wake Timers..." -ForegroundColor Yellow
try {
    # 0 = Disabled
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 0 | Out-Null
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 0 | Out-Null
    powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
    Write-Host "  [+] Disabled wake timers for Plugged In (AC) and Battery (DC)" -ForegroundColor Green
} catch {
    Write-Host "  [-] Could not set powercfg wake timers: $_" -ForegroundColor Gray
}

# 6. Telemetry & Diagnostic Services (Set to Manual)
Write-Host "`n[6/6] Setting Telemetry Diagnostic Services to Manual..." -ForegroundColor Yellow
$services = @("DiagTrack", "dmwappushservice", "diagnosticshub.standardcollector.service")
foreach ($svc in $services) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
        Write-Host "  [+] Stopped and set to Manual: $svc" -ForegroundColor Green
    } else {
        Write-Host "  [i] Service not found or already absent: $svc" -ForegroundColor Gray
    }
}

# 7. Restart Windows Explorer to apply UI tweaks
Write-Host "`n[*] Restarting Windows Explorer to apply changes immediately..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  Stage 3 Applied Successfully! Desktop Optimized.        " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
