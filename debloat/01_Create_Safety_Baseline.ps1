<#
.SYNOPSIS
    Step 1: Safety Baseline Creation for Windows 11 Debloat.
.DESCRIPTION
    Creates a System Restore Point and exports baseline registry hives prior to applying any debloat modifications.
#>

[CmdletBinding()]
param(
    [string]$BackupDir = "C:\Debloat Windows 11\Backups"
)

function Test-IsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$isAdmin = Test-IsAdmin

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Windows 11 Debloat: Step 1 Safety Baseline Creation    " -ForegroundColor Cyan
Write-Host "   Administrative Privileges: $(if ($isAdmin) {'ELEVATED (YES)'} else {'STANDARD (NO)'})" -ForegroundColor $(if ($isAdmin) {'Green'} else {'Yellow'})
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Ensure backup directory exists
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Write-Host "[+] Created backup directory at: $BackupDir" -ForegroundColor Green
} else {
    Write-Host "[i] Backup directory exists at: $BackupDir" -ForegroundColor Gray
}

# 1. System Restore Point
Write-Host "`n--- 1. System Restore Point ---" -ForegroundColor Cyan
if ($isAdmin) {
    try {
        # Unlock 24-hour restore point frequency limit
        $srKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
        if (Test-Path $srKey) {
            Set-ItemProperty -Path $srKey -Name "SystemRestorePointCreationFrequency" -Value 0 -Type DWord -Force
            Write-Host "[+] Set SystemRestorePointCreationFrequency = 0 (unthrottled)" -ForegroundColor Green
        }

        # Enable computer restore on system drive C:
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Write-Host "[+] Ensured System Protection is ENABLED on drive C:\" -ForegroundColor Green

        # Create restore point
        $rpName = "Pre-Debloat Baseline (Clean State)"
        Write-Host "[*] Creating System Restore Point: '$rpName'..." -ForegroundColor Yellow
        Checkpoint-Computer -Description $rpName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "[SUCCESS] Restore Point created successfully!" -ForegroundColor Green
    } catch {
        Write-Warning "[-] Could not create System Restore Point: $_"
    }
} else {
    Write-Host "[!] Note: System Restore Point creation requires Administrator privileges." -ForegroundColor Yellow
    Write-Host "[!] You can run 'Run_Step1_Baseline_Admin.cmd' as Administrator to create the restore point." -ForegroundColor Yellow
}

# 2. Export Baseline Registry Hives
Write-Host "`n--- 2. Exporting Baseline Registry Hives ---" -ForegroundColor Cyan

$regTargets = @(
    @{ Path = "HKLM\SOFTWARE\Policies\Microsoft\Windows"; File = "HKLM_Policies_Windows_Baseline.reg" },
    @{ Path = "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; File = "HKCU_ContentDeliveryManager_Baseline.reg" },
    @{ Path = "HKCU\Software\Microsoft\Windows\CurrentVersion\Search"; File = "HKCU_Search_Baseline.reg" },
    @{ Path = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; File = "HKCU_Explorer_Advanced_Baseline.reg" },
    @{ Path = "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack"; File = "HKLM_Service_DiagTrack_Baseline.reg" },
    @{ Path = "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice"; File = "HKLM_Service_dmwappushservice_Baseline.reg" }
)

foreach ($target in $regTargets) {
    $outFile = Join-Path $BackupDir $target.File
    $proc = Start-Process reg -ArgumentList "export `"$($target.Path)`" `"$outFile`" /y" -Wait -NoNewWindow -PassThru
    if ($proc.ExitCode -eq 0 -and (Test-Path $outFile)) {
        $size = (Get-Item $outFile).Length
        Write-Host "[+] Exported $($target.Path) -> $($target.File) ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "[-] Skipped / Inaccessible: $($target.Path)" -ForegroundColor Gray
    }
}

# 3. Snapshot Installed & Provisioned AppX Packages
Write-Host "`n--- 3. Snapshotting AppX Packages ---" -ForegroundColor Cyan
$appxReportPath = Join-Path $BackupDir "Installed_AppX_Packages_Baseline.txt"
Get-AppxPackage | Select-Object Name, PackageFullName, InstallLocation | Sort-Object Name | Out-File -FilePath $appxReportPath -Encoding utf8
Write-Host "[+] AppX package inventory saved to: $appxReportPath" -ForegroundColor Green

$provReportPath = Join-Path $BackupDir "Provisioned_AppX_Packages_Baseline.txt"
Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Select-Object DisplayName, PackageName | Sort-Object DisplayName | Out-File -FilePath $provReportPath -Encoding utf8
if (Test-Path $provReportPath) {
    Write-Host "[+] Provisioned AppX package inventory saved to: $provReportPath" -ForegroundColor Green
}

# 4. Final Status Summary
Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "   Safety Baseline Step 1 Execution Completed!             " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
