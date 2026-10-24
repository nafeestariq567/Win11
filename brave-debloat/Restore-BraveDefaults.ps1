<#
.SYNOPSIS
    Restores Brave & Brave Beta to default configuration.
.DESCRIPTION
    Removes enterprise group policy entries from HKCU and HKLM.
#>

Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host "       Restoring Brave & Brave Beta Default Policies      " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host ""

$targets = @(
    "HKCU:\SOFTWARE\Policies\BraveSoftware\Brave",
    "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
)

foreach ($target in $targets) {
    if (Test-Path $target) {
        try {
            Remove-Item -Path $target -Recurse -Force
            Write-Host "[OK] Removed policies at $target" -ForegroundColor Green
        }
        catch {
            Write-Warning "Could not remove $target. Make sure you run PowerShell as Administrator."
        }
    } else {
        Write-Host "[INFO] Path $target does not exist. Already clean." -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Done! Restart Brave or Brave Beta to return to default behavior." -ForegroundColor Cyan
