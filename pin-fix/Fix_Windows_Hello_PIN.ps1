<#
.SYNOPSIS
    Fix and Reset Windows Hello PIN Container (Error 0xD000A002 & Hibernate Crash Prevention).
.DESCRIPTION
    1. Stops Passport/Credential services.
    2. Takes ownership and purges corrupted Windows Hello cryptographic containers in Ngc.
    3. Re-enables authentication services.
    4. Disables the 3-hour sleep-to-hibernate timeout that caused the crash reboot on resume.
    5. Re-initializes hiberfil.sys.
    6. Launches Settings so the user can set a fresh, reliable PIN.
.NOTES
    Tailored for: Acer Predator PH317-53 / Windows 11 Pro.
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

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     Windows Hello PIN Corruption & Crash Resolver        " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$ngcPath = "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"

# Step 1: Temporarily stop Passport container services
Write-Host "[1/4] Stopping Windows Hello & Credential Services..." -ForegroundColor Yellow
Stop-Service -Name "NgcCtnrSvc" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "VaultSvc" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Step 2: Take ownership and clear corrupted Ngc folder
Write-Host "`n[2/4] Resetting Corrupted Windows Hello Container (Ngc)..." -ForegroundColor Yellow
if (Test-Path $ngcPath) {
    try {
        # Take ownership
        $null = & takeown /F "$ngcPath" /r /d y 2>$null
        $null = & icacls "$ngcPath" /grant "administrators:F" /t /c /q 2>$null

        # Backup & remove subfolders
        $items = Get-ChildItem -Path $ngcPath -Force -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  [+] Removed corrupted container item: $($item.Name)" -ForegroundColor Green
        }
        Write-Host "  [SUCCESS] Ngc container directory cleared and reset." -ForegroundColor Green
    } catch {
        Write-Warning "  [-] Error accessing Ngc folder: $_"
    }
} else {
    Write-Host "  [i] Ngc folder does not exist or already clean." -ForegroundColor Gray
}

# Step 3: Restart services
Write-Host "`n[3/4] Restarting Authentication Services..." -ForegroundColor Yellow
Start-Service -Name "VaultSvc" -ErrorAction SilentlyContinue
Start-Service -Name "NgcCtnrSvc" -ErrorAction SilentlyContinue
Write-Host "  [+] Credential & Passport services restarted." -ForegroundColor Green

# Step 4: Fix the Root Cause (Prevent Hibernate Resume Crash)
Write-Host "`n[4/4] Fixing Root Cause: Preventing Sleep-to-Hibernate Resume Crash..." -ForegroundColor Yellow
try {
    # Set Hibernate After to 0 (Never) so sleep doesn't crash after 3 hours
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0 | Out-Null
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0 | Out-Null
    powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
    Write-Host "  [+] Set 'Hibernate after' to NEVER (0 seconds) on AC and Battery" -ForegroundColor Green

    # Recreate clean hiberfil.sys
    powercfg -h off | Out-Null
    powercfg -h on | Out-Null
    Write-Host "  [+] Re-initialized clean hibernation storage (hiberfil.sys)" -ForegroundColor Green
} catch {
    Write-Host "  [-] Could not modify power settings: $_" -ForegroundColor Gray
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  Repair Complete! Ready to set up your fresh PIN.        " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "[*] Opening Windows Sign-in Options in 3 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

# Launch Sign-in options
Start-Process "ms-settings:signinoptions"
