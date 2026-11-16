<#
.SYNOPSIS
    Win11 Battery Sleep Watchdog (24-Hour Sleep Cap + 10% Low-Battery Safety Net)
.DESCRIPTION
    Periodically checks battery state and sleep duration when running on battery (DC):
    1. Low-Battery Safety Net: If battery drops to <= 10% during sleep, cleanly shuts down
       the laptop before reaching 0%, preventing hard power cuts, TPM lockout, and NVMe brownout.
    2. 24-Hour Sleep Cap: If the laptop has been sleeping on battery for >= 24 hours,
       cleanly shuts down to preserve remaining battery and prevent drain over long weekends.
    3. Normal Routine: Leaves sleep completely uninterrupted for 14, 16, or 18 hours if battery is healthy (>10%).
    4. AC Power: Automatically inactive when connected to AC charger.
.NOTES
    Repository: https://github.com/nafeestariq567/Win11/tree/main/pin-fix
#>

[CmdletBinding()]
param()

$logPath = "C:\Win11\pin-fix\watchdog.log"

function Write-WatchdogLog {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logLine = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logLine -ErrorAction SilentlyContinue
        # Rotate log if it exceeds 300 lines
        if (Test-Path $logPath) {
            $lines = Get-Content -Path $logPath -ErrorAction SilentlyContinue
            if ($lines.Count -gt 300) {
                $lines | Select-Object -Last 200 | Set-Content -Path $logPath -Force -ErrorAction SilentlyContinue
            }
        }
    } catch { }
}

try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    $powerStatus = [System.Windows.Forms.SystemInformation]::PowerStatus
    $lineStatus = $powerStatus.PowerLineStatus
} catch {
    $lineStatus = "Unknown"
}

try {
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    $batteryPct = if ($battery) { [int]$battery.EstimatedChargeRemaining } else { [int]($powerStatus.BatteryLifePercent * 100) }
} catch {
    $batteryPct = 100
}

# 1. AC Charger Connected: System is safe and charging.
if ($lineStatus -eq "Online") {
    if (-not (Test-Path $logPath) -or ((Get-Item $logPath).Length -eq 0)) {
        Write-WatchdogLog "[AC ONLINE] System connected to AC charger (Battery: $batteryPct%). Safe & charging. Watchdog standing by."
    }
    exit 0
}

# Inspect Sleep and Wake Events
$lastSleep = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Kernel-Power'; ID=42} -MaxEvents 1 -ErrorAction SilentlyContinue
$lastWake = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Power-Troubleshooter'; ID=1} -MaxEvents 1 -ErrorAction SilentlyContinue

$isUserActive = $false
$sleepDurationHours = 0.0

if ($lastSleep) {
    if ($lastWake -and ($lastWake.TimeCreated -gt $lastSleep.TimeCreated)) {
        # Check wake source: if user woke the machine via button, lid, or USB, user is actively working.
        if ($lastWake.Message -match 'Wake Source:\s*(Power Button|Device|Lid|Fixed Feature)') {
            $isUserActive = $true
        } else {
            # Unattended wake (Timer / RTC wake) - system was asleep and woke for this check
            $sleepDurationHours = ((Get-Date) - $lastSleep.TimeCreated).TotalHours
        }
    } else {
        # Currently transitioning or still in sleep session
        $sleepDurationHours = ((Get-Date) - $lastSleep.TimeCreated).TotalHours
    }
}

# If the user is actively using the laptop, do not interfere.
if ($isUserActive) {
    Write-WatchdogLog "User is actively using laptop on battery (Battery: $batteryPct%). Watchdog in standby."
    exit 0
}

# RULE 1: Low-Battery Safety Net (<= 10%)
if ($batteryPct -le 10) {
    Write-WatchdogLog "[SAFETY NET TRIGGERED] Battery dropped to $batteryPct% during sleep. Initiating graceful shutdown to protect TPM & NVMe."
    & shutdown.exe /s /t 30 /c "Win11 Watchdog: Battery dropped to 10% during sleep. Shutting down cleanly to protect TPM & data."
    exit 0
}

# RULE 2: 24-Hour Continuous Battery Sleep Cap (>= 24 Hours)
if ($sleepDurationHours -ge 24.0) {
    $roundedHours = [math]::Round($sleepDurationHours, 1)
    Write-WatchdogLog "[24-HOUR CAP TRIGGERED] System has been sleeping on battery for $roundedHours hours. Initiating graceful shutdown to preserve battery."
    & shutdown.exe /s /t 30 /c "Win11 Watchdog: 24-hour sleep cap on battery reached. Shutting down cleanly to protect system."
    exit 0
}

# RULE 3: Normal Routine Sleep (14-18 hours, Battery > 10%)
$roundedHours = [math]::Round($sleepDurationHours, 1)
Write-WatchdogLog "[OK] Sleep check passed: Battery at $batteryPct%, Sleep duration: $roundedHours hrs. Routine sleep continues."
exit 0
