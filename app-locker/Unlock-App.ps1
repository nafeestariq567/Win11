#Requires -Version 5.1
[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $false)]
    [string]$ShortcutName
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$appsDir   = Join-Path $scriptDir "apps"

if (-not (Test-Path $appsDir)) {
    Write-Host "No locked applications found (apps folder is empty)." -ForegroundColor Yellow
    exit 0
}

$jsonFiles = Get-ChildItem -Path $appsDir -Filter "*.json"

if ($jsonFiles.Count -eq 0) {
    Write-Host "No locked applications are currently registered." -ForegroundColor Yellow
    exit 0
}

$selectedJson = $null

if ([string]::IsNullOrWhiteSpace($ShortcutName)) {
    Write-Host "`n=== Universal Desktop App Locker - Unlock / Restore App ===" -ForegroundColor Cyan
    Write-Host "Select an application to unlock:`n" -ForegroundColor Gray

    for ($i = 0; $i -lt $jsonFiles.Count; $i++) {
        $data = Get-Content -Path $jsonFiles[$i].FullName -Raw | ConvertFrom-Json
        Write-Host ("  [{0,2}] {1,-35} (Key: {2})" -f ($i + 1), $data.DisplayName, $data.AppKey) -ForegroundColor White
    }

    Write-Host ""
    $choice = Read-Host "Enter the number or name of the app to unlock (or 'q' to quit)"
    if ($choice -match '^[Qq]$' -or [string]::IsNullOrWhiteSpace($choice)) {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }

    if ($choice -match '^\d+$') {
        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $jsonFiles.Count) {
            $selectedJson = $jsonFiles[$idx]
        } else {
            Write-Error "Invalid selection index."
            exit 1
        }
    } else {
        $selectedJson = $jsonFiles | Where-Object {
            $_.BaseName -eq $choice -or
            (Get-Content $_.FullName -Raw | ConvertFrom-Json).DisplayName -eq $choice
        } | Select-Object -First 1

        if (-not $selectedJson) {
            Write-Error "Locked app '$choice' not found."
            exit 1
        }
    }
} else {
    $selectedJson = $jsonFiles | Where-Object {
        $_.BaseName -like "*$ShortcutName*" -or
        (Get-Content $_.FullName -Raw | ConvertFrom-Json).DisplayName -like "*$ShortcutName*"
    } | Select-Object -First 1

    if (-not $selectedJson) {
        Write-Error "Locked app matching '$ShortcutName' was not found."
        exit 1
    }
}

$appData = Get-Content -Path $selectedJson.FullName -Raw | ConvertFrom-Json
$appKey = $appData.AppKey
$displayName = $appData.DisplayName
$targetShortcutPath = $appData.ShortcutPath
$backupLnkPath = Join-Path $appsDir "$appKey.original.lnk"

# Restore Method 1: Copy exact original .lnk backup if available
if (Test-Path $backupLnkPath) {
    Copy-Item -Path $backupLnkPath -Destination $targetShortcutPath -Force
} else {
    # Restore Method 2: Recreate using metadata
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($targetShortcutPath)
    $shortcut.TargetPath       = $appData.TargetPath
    $shortcut.Arguments        = $appData.Arguments
    $shortcut.WorkingDirectory = $appData.WorkingDirectory
    $shortcut.IconLocation     = $appData.IconLocation
    $shortcut.Save()
}

# Clean up registration
Remove-Item -Path $selectedJson.FullName -Force -ErrorAction SilentlyContinue
if (Test-Path $backupLnkPath) {
    Remove-Item -Path $backupLnkPath -Force -ErrorAction SilentlyContinue
}

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host " SUCCESS: '$displayName' has been restored to normal!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host " Desktop shortcut has been reverted to direct execution." -ForegroundColor Gray
Write-Host " No password will be required when launching '$displayName'." -ForegroundColor Cyan
