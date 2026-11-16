<#
.SYNOPSIS
    Uninstalls the Win11 Battery Sleep Watchdog.
.DESCRIPTION
    Removes the 'Win11_Battery_Sleep_Watchdog' scheduled task and restores default wake settings.
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

$taskName = "Win11_Battery_Sleep_Watchdog"

try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
    Write-Host "[SUCCESS] Watchdog task '$taskName' removed." -ForegroundColor Green
} catch {
    Write-Host "[i] Task '$taskName' was not found or already removed." -ForegroundColor Gray
}

Start-Sleep -Seconds 2
