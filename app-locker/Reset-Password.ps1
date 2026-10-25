#Requires -Version 5.1
[CmdletBinding()]
param ()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configDir = Join-Path $scriptDir "config"
$hashFile  = Join-Path $configDir "master.hash"

Write-Host "`n=== Universal Desktop App Locker - Reset Master Password ===" -ForegroundColor Cyan

if (-not (Test-Path $hashFile)) {
    Write-Host "No master password is currently set. It will be created on the next launch of a locked app." -ForegroundColor Yellow
    exit 0
}

Write-Host "Choose an option:" -ForegroundColor Gray
Write-Host "  [1] Clear master password (will prompt to set a new password on next app launch)" -ForegroundColor White
Write-Host "  [2] Set a new master password right now in this terminal" -ForegroundColor White
Write-Host "  [q] Cancel" -ForegroundColor Gray

$choice = Read-Host "`nEnter choice"
if ($choice -eq "1") {
    Remove-Item -Path $hashFile -Force
    Write-Host "`n[OK] Master password cleared! The next time you open any locked app, it will ask you to set a new password." -ForegroundColor Green
} elseif ($choice -eq "2") {
    $pwd1 = Read-Host -Prompt "Enter new Master Password" -AsSecureString
    $pwd2 = Read-Host -Prompt "Confirm new Master Password" -AsSecureString

    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd1)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd2)
    $plain1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
    $plain2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)

    if ($plain1.Length -lt 4) {
        Write-Error "Password must be at least 4 characters."
        exit 1
    }
    if ($plain1 -cne $plain2) {
        Write-Error "Passwords do not match."
        exit 1
    }

    # Generate salt & hash
    $salt = New-Object byte[] 16
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($salt)

    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $pwdBytes = [System.Text.Encoding]::UTF8.GetBytes($plain1)
    $combined = New-Object byte[] ($salt.Length + $pwdBytes.Length)
    [Array]::Copy($salt, 0, $combined, 0, $salt.Length)
    [Array]::Copy($pwdBytes, 0, $combined, $salt.Length, $pwdBytes.Length)
    $hashBytes = $hasher.ComputeHash($combined)

    $hexSalt = [BitConverter]::ToString($salt).Replace('-', '').ToLower()
    $hexHash = [BitConverter]::ToString($hashBytes).Replace('-', '').ToLower()

    Set-Content -Path $hashFile -Value "${hexSalt}:${hexHash}" -Force
    Write-Host "`n[OK] Master password successfully updated!" -ForegroundColor Green
} else {
    Write-Host "Cancelled." -ForegroundColor Yellow
}
