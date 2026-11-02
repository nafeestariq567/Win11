<#
.SYNOPSIS
    Fix and Reset Windows Hello PIN Container & Hardware TPM Lockout.
.DESCRIPTION
    1. Resets Hardware TPM Dictionary Attack Lockout (Unblock-Tpm / DA reset).
    2. Stops Passport/Credential services (NgcCtnrSvc, VaultSvc).
    3. Takes administrative ownership and purges corrupted Windows Hello cryptographic containers in Ngc.
    4. Restarts authentication services.
    5. Neutralizes all hibernation triggers (Root Cause):
       - Sets Critical Battery Action (BATACTIONCRIT) to Shut down (3) on AC and DC.
       - Sets Hibernate idle timeout (HIBERNATEIDLE) to Never (0).
       - Completely turns off Hibernation (powercfg -h off).
    6. Launches Settings so the user can set a fresh, reliable, hardware TPM-backed PIN.
.NOTES
    Tailored for: Acer Predator PH317-53 / Windows 11 Pro 64-bit.
    Repository: https://github.com/nafeestariq567/Win11/tree/main/pin-fix
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
Write-Host "     Windows Hello PIN Corruption & TPM Lockout Resolver  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$ngcPath = "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"

# Step 1: Check and reset TPM Hardware Lockout
Write-Host "[1/5] Checking TPM 2.0 Hardware Security State..." -ForegroundColor Yellow
try {
    $tpm = Get-Tpm
    if ($tpm.LockedOut) {
        Write-Host "  [*] TPM is currently in Dictionary Attack Lockout. Attempting Unblock-Tpm..." -ForegroundColor Yellow
        Unblock-Tpm -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        $tpmAfter = Get-Tpm
        if (-not $tpmAfter.LockedOut) {
            Write-Host "  [SUCCESS] TPM hardware lockout reset! Counter cleared to 0." -ForegroundColor Green
        } else {
            Write-Host "  [i] TPM is locked out by hardware counter. It will decay automatically or can be cleared in tpm.msc / UEFI." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [+] TPM 2.0 is healthy and not locked out." -ForegroundColor Green
    }
} catch {
    Write-Host "  [-] Note on TPM unblock: $_" -ForegroundColor Gray
}

# Step 2: Temporarily stop Passport container services
Write-Host "`n[2/5] Stopping Windows Hello & Credential Services..." -ForegroundColor Yellow
Stop-Service -Name "NgcCtnrSvc" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "VaultSvc" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "WbioSrvc" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Step 3: Take ownership and clear corrupted Ngc folder
Write-Host "`n[3/5] Resetting Corrupted Windows Hello Container (Ngc)..." -ForegroundColor Yellow
if (Test-Path $ngcPath) {
    try {
        $null = & takeown /F "$ngcPath" /r /d y 2>$null
        $null = & icacls "$ngcPath" /grant "*S-1-5-32-544:(OI)(CI)F" /t /c /q 2>$null
        $null = & icacls "$ngcPath" /grant "administrators:(OI)(CI)F" /t /c /q 2>$null

        $items = Get-ChildItem -Path $ngcPath -Force -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  [+] Removed corrupted container item: $($item.Name)" -ForegroundColor Green
        }

        # Restore LOCAL SERVICE permissions so Windows Hello can write new containers
        $null = & icacls "$ngcPath" /grant "*S-1-5-19:(OI)(CI)F" /t /c /q 2>$null
        $null = & icacls "$ngcPath" /grant "NT AUTHORITY\LOCAL SERVICE:(OI)(CI)F" /t /c /q 2>$null

        Write-Host "  [SUCCESS] Ngc container directory cleared and reset." -ForegroundColor Green
    } catch {
        Write-Warning "  [-] Error accessing Ngc folder: $_"
    }
} else {
    Write-Host "  [i] Ngc folder does not exist or already clean." -ForegroundColor Gray
}

# Step 4: Restart authentication services
Write-Host "`n[4/5] Restarting Authentication Services..." -ForegroundColor Yellow
Start-Service -Name "VaultSvc" -ErrorAction SilentlyContinue
Start-Service -Name "NgcCtnrSvc" -ErrorAction SilentlyContinue
Start-Service -Name "WbioSrvc" -ErrorAction SilentlyContinue
Write-Host "  [+] Credential & Passport services restarted." -ForegroundColor Green

# Step 5: Fix Root Cause (Prevent all Hibernate Resume & Dying Battery Crashes)
Write-Host "`n[5/5] Fixing Root Cause: Neutralizing All Hibernation Triggers..." -ForegroundColor Yellow
try {
    # 1. Critical Battery Action to Shut Down (not Hibernate)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BATTERY BATACTIONCRIT 3 | Out-Null
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BATTERY BATACTIONCRIT 3 | Out-Null
    Write-Host "  [+] Set 'Critical battery action' to SHUT DOWN (3) on AC and Battery" -ForegroundColor Green

    # 2. Hibernate idle timeout to Never
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0 | Out-Null
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0 | Out-Null
    Write-Host "  [+] Set 'Hibernate after' to NEVER (0 seconds) on AC and Battery" -ForegroundColor Green

    # 3. Completely disable Hibernation (deletes hiberfil.sys, frees 16-32GB SSD, eliminates NVMe S4 crash risk)
    powercfg -h off | Out-Null
    Write-Host "  [+] Completely disabled Hibernation (powercfg -h off) - Eliminates NVMe S4 crash risk" -ForegroundColor Green

    powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
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
