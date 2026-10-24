<#
.SYNOPSIS
    Rollback for Stage 3: Restores Explorer, Taskbar, Edge, Power & Services to Windows Defaults.
.DESCRIPTION
    Reverts all UI settings, re-enables Edge background boost, restores 400ms MenuShowDelay,
    and resets diagnostic services back to Automatic.
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
Write-Host "  Rollback Stage 3: Restoring Explorer & UI to Defaults   " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow
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
    Write-Host "  [+] Restored default: $Path\$Name = $Value" -ForegroundColor Green
}

# 1. Explorer Settings
Write-Host "[1/6] Restoring File Explorer Defaults..." -ForegroundColor Cyan
$advExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-RegistryValueSafe -Path $advExplorer -Name "HideFileExt" -Value 1
Set-RegistryValueSafe -Path $advExplorer -Name "Hidden" -Value 2
Set-RegistryValueSafe -Path $advExplorer -Name "NoNetCrawling" -Value 0

# 2. Taskbar Settings
Write-Host "`n[2/6] Restoring Taskbar Defaults..." -ForegroundColor Cyan
Set-RegistryValueSafe -Path "$advExplorer\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -Value 0
Set-RegistryValueSafe -Path $advExplorer -Name "TaskbarMn" -Value 1
Set-RegistryValueSafe -Path $advExplorer -Name "TaskbarDa" -Value 1

# 3. MenuShowDelay
Write-Host "`n[3/6] Restoring MenuShowDelay to 400ms..." -ForegroundColor Cyan
Set-RegistryValueSafe -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "400" -Type "String"

# 4. Microsoft Edge Policies
Write-Host "`n[4/6] Restoring Edge Background Settings..." -ForegroundColor Cyan
$edgePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (Test-Path $edgePolicy) {
    Remove-ItemProperty -Path $edgePolicy -Name "StartupBoostEnabled" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $edgePolicy -Name "BackgroundModeEnabled" -Force -ErrorAction SilentlyContinue
}

# 5. Sleep Wake Timers
Write-Host "`n[5/6] Restoring Sleep Wake Timers..." -ForegroundColor Cyan
try {
    # 1 = Enabled
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 1 | Out-Null
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 1 | Out-Null
    powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
    Write-Host "  [+] Restored wake timers to Enabled" -ForegroundColor Green
} catch {
    Write-Host "  [-] Could not reset powercfg wake timers: $_" -ForegroundColor Gray
}

# 6. Services
Write-Host "`n[6/6] Restoring DiagTrack Service to Automatic..." -ForegroundColor Cyan
if (Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue) {
    Set-Service -Name "DiagTrack" -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
    Write-Host "  [+] DiagTrack restored to Automatic and Started" -ForegroundColor Green
}

# 7. Restart Explorer
Write-Host "`n[*] Restarting Windows Explorer..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  Stage 3 Restored Successfully!                          " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
