<#
.SYNOPSIS
    Installs the Win11 Battery Sleep Watchdog (24h Cap + 10% Low Battery Safety Net).
.DESCRIPTION
    1. Enables RTC Wake Timers (powercfg RTCWAKE 1).
    2. Configures unattended sleep timeout to 60s.
    3. Registers the 'Win11_Battery_Sleep_Watchdog' Scheduled Task to run every 1 hour with WakeToRun privileges.
    4. Runs as NT AUTHORITY\SYSTEM so it protects the laptop even while locked or logged off.
.NOTES
    Repository: https://github.com/nafeestariq567/Win11/tree/main/pin-fix
#>

[CmdletBinding()]
param()

function Test-IsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$isAdmin = Test-IsAdmin

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Installing Win11 Battery Sleep Watchdog Safety Suite   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""
if ($isAdmin) {
    Write-Host "[+] Running with Administrator privileges (Configuring as SYSTEM service)" -ForegroundColor Green
} else {
    Write-Host "[i] Running with User privileges (Configuring under $env:USERNAME)" -ForegroundColor Yellow
}

$taskName = "Win11_Battery_Sleep_Watchdog"
$scriptPath = "C:\Win11\pin-fix\Watchdog_Battery_Sleep.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Error "[-] Error: Watchdog script not found at $scriptPath"
    exit 1
}

# 1. Enable Hardware RTC Wake Timers
Write-Host "[1/4] Enabling RTC Wake Timers in Windows Power Policy..." -ForegroundColor Yellow
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 1 | Out-Null
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP RTCWAKE 1 | Out-Null
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP UNATTENDSLEEP 60 | Out-Null
powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
Write-Host "  [+] RTC Wake Timers enabled on DC and AC." -ForegroundColor Green
Write-Host "  [+] Unattended sleep timeout set to 60 seconds on DC." -ForegroundColor Green

# 2. Configure Scheduled Task Action & Settings
Write-Host "`n[2/4] Configuring Watchdog Scheduled Task..." -ForegroundColor Yellow

$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""

# Trigger: Runs every 1 hour indefinitely (10-year span)
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration (New-TimeSpan -Days 3650)

$settings = New-ScheduledTaskSettingsSet `
    -WakeToRun `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -MultipleInstances IgnoreNew

if ($isAdmin) {
    $principal = New-ScheduledTaskPrincipal `
        -UserId "NT AUTHORITY\SYSTEM" `
        -LogonType ServiceAccount `
        -RunLevel Highest
} else {
    $principal = New-ScheduledTaskPrincipal `
        -UserId $env:USERNAME `
        -LogonType Interactive
}

# 3. Register the Task
Write-Host "`n[3/4] Registering Task in Windows Task Scheduler..." -ForegroundColor Yellow
try {
    # Unregister existing if present
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "Win11 Battery Sleep Watchdog: Wakes hourly during sleep on battery. Shuts down cleanly at 24h cap or 10% reserve to protect TPM and NVMe." `
        -Force | Out-Null

    $runAsUser = if ($isAdmin) { "SYSTEM (Elevated)" } else { "$env:USERNAME (User)" }
    Write-Host "  [SUCCESS] Task '$taskName' registered under $runAsUser with WakeToRun." -ForegroundColor Green
} catch {
    Write-Error "[-] Failed to register task: $_"
    exit 1
}

# 4. Dry Run Verification
Write-Host "`n[4/4] Performing Dry-Run Verification..." -ForegroundColor Yellow
try {
    Start-ScheduledTask -TaskName $taskName
    Start-Sleep -Seconds 2
    $taskInfo = Get-ScheduledTask -TaskName $taskName
    Write-Host "  [+] Task State: $($taskInfo.State)" -ForegroundColor Green

    $logFile = "C:\Win11\pin-fix\watchdog.log"
    if (Test-Path $logFile) {
        $lastLog = Get-Content -Path $logFile -Tail 1
        Write-Host "  [+] Verified Log: $lastLog" -ForegroundColor Gray
    }
} catch {
    Write-Host "  [-] Note on dry run: $_" -ForegroundColor Gray
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  Watchdog Safety Suite Successfully Active!              " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  - Daily routine (14-18 hrs): 100% uninterrupted sleep." -ForegroundColor Cyan
Write-Host "  - 24-Hour cap: Auto-shuts down if left sleeping 24 hrs." -ForegroundColor Cyan
Write-Host "  - 10% Safety net: Auto-shuts down if battery reaches 10%." -ForegroundColor Cyan
Write-Host "  - AC Wall Power: Completely idle, charging to 100%." -ForegroundColor Cyan
Write-Host ""
Start-Sleep -Seconds 3
