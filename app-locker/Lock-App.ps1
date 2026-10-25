#Requires -Version 5.1
[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $false)]
    [string]$ShortcutName
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$appsDir   = Join-Path $scriptDir "apps"
$exePath   = Join-Path $scriptDir "AppLocker.exe"
$desktop   = [Environment]::GetFolderPath("Desktop")

if (-not (Test-Path $appsDir)) {
    New-Item -ItemType Directory -Path $appsDir -Force | Out-Null
}

$wsh = New-Object -ComObject WScript.Shell

# List all desktop shortcuts
$allShortcuts = Get-ChildItem -Path $desktop -Filter "*.lnk" | Sort-Object Name

if ($allShortcuts.Count -eq 0) {
    Write-Warning "No desktop shortcuts found in $desktop."
    exit 0
}

$selectedLnk = $null

if ([string]::IsNullOrWhiteSpace($ShortcutName)) {
    Write-Host "`n=== Universal Desktop App Locker - Lock App ===" -ForegroundColor Cyan
    Write-Host "Select an application shortcut to lock:`n" -ForegroundColor Gray

    for ($i = 0; $i -lt $allShortcuts.Count; $i++) {
        $name = $allShortcuts[$i].BaseName
        $target = $wsh.CreateShortcut($allShortcuts[$i].FullName)
        $isLocked = ($target.TargetPath -like "*AppLocker.exe*" -or $target.Arguments -like "*Launch-Silent.vbs*")
        $status = if ($isLocked) { "[ALREADY LOCKED]" } else { "" }
        $color = if ($isLocked) { "DarkYellow" } else { "White" }
        Write-Host ("  [{0,2}] {1,-35} {2}" -f ($i + 1), $name, $status) -ForegroundColor $color
    }

    Write-Host ""
    $choice = Read-Host "Enter the number or exact name of the shortcut to lock (or 'q' to quit)"
    if ($choice -match '^[Qq]$' -or [string]::IsNullOrWhiteSpace($choice)) {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }

    if ($choice -match '^\d+$') {
        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $allShortcuts.Count) {
            $selectedLnk = $allShortcuts[$idx]
        } else {
            Write-Error "Invalid selection index."
            exit 1
        }
    } else {
        $selectedLnk = $allShortcuts | Where-Object { $_.BaseName -eq $choice -or $_.Name -eq $choice } | Select-Object -First 1
        if (-not $selectedLnk) {
            Write-Error "Shortcut '$choice' was not found on your Desktop."
            exit 1
        }
    }
} else {
    $selectedLnk = $allShortcuts | Where-Object {
        $_.BaseName -eq $ShortcutName -or
        $_.Name -eq $ShortcutName -or
        $_.BaseName -like "*$ShortcutName*"
    } | Select-Object -First 1

    if (-not $selectedLnk) {
        Write-Error "Shortcut matching '$ShortcutName' was not found on your Desktop."
        exit 1
    }
}

$lnkPath = $selectedLnk.FullName
$baseName = $selectedLnk.BaseName
$shortcut = $wsh.CreateShortcut($lnkPath)

if ($shortcut.TargetPath -like "*AppLocker.exe*" -or $shortcut.Arguments -like "*Launch-Silent.vbs*") {
    Write-Host "`n'$baseName' is already locked!" -ForegroundColor Yellow
    exit 0
}

# Generate clean alphanumeric AppKey
$appKey = ($baseName -replace '[^a-zA-Z0-9_\-]', '-').ToLower().Trim('-')
while ($appKey -match '--') { $appKey = $appKey.Replace('--', '-') }
if ([string]::IsNullOrWhiteSpace($appKey)) { $appKey = "app-" + (Get-Random) }

# Capture original attributes
$originalTarget    = $shortcut.TargetPath
$originalArgs      = $shortcut.Arguments
$originalWorkDir   = $shortcut.WorkingDirectory
$originalIcon      = $shortcut.IconLocation

# Fallback: if icon location is not explicitly set, anchor it to the target executable
if ([string]::IsNullOrWhiteSpace($originalIcon) -or $originalIcon -match '^,0?$') {
    $originalIcon = "$originalTarget,0"
}

# Save backup copy of the original .lnk file
$backupLnkPath = Join-Path $appsDir "$appKey.original.lnk"
Copy-Item -Path $lnkPath -Destination $backupLnkPath -Force

# Create JSON metadata record
$appRecord = [PSCustomObject]@{
    AppKey           = $appKey
    DisplayName      = $baseName
    ShortcutPath     = $lnkPath
    TargetPath       = $originalTarget
    Arguments        = $originalArgs
    WorkingDirectory = $originalWorkDir
    IconLocation     = $originalIcon
    LockedAt         = (Get-Date).ToString("o")
}

$jsonPath = Join-Path $appsDir "$appKey.json"
$appRecord | ConvertTo-Json -Depth 4 | Set-Content -Path $jsonPath -Force

# Update the Desktop shortcut to point to AppLocker.exe
$shortcut.TargetPath       = $exePath
$shortcut.Arguments        = "`"$appKey`""
$shortcut.WorkingDirectory = $scriptDir
$shortcut.IconLocation     = $originalIcon
$shortcut.Save()

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host " SUCCESS: '$baseName' is now locked with App Locker!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host " Desktop Shortcut : $lnkPath" -ForegroundColor Gray
Write-Host " Real Target      : $originalTarget" -ForegroundColor Gray
if ($originalArgs) {
    Write-Host " Preserved Args   : $originalArgs" -ForegroundColor Gray
}
Write-Host " Preserved Icon   : $originalIcon" -ForegroundColor Gray
Write-Host " App Key          : $appKey" -ForegroundColor Gray
Write-Host " Config Saved     : $jsonPath" -ForegroundColor Gray
Write-Host "`nWhen you double-click '$baseName' on your Desktop, it will require your Master Password." -ForegroundColor Cyan
