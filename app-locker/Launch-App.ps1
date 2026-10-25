#Requires -Version 5.1
param (
    [Parameter(Mandatory = $true)]
    [string]$AppKey
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$configDir = Join-Path $scriptDir "config"
$appsDir   = Join-Path $scriptDir "apps"
$hashFile  = Join-Path $configDir "master.hash"
$appJson   = Join-Path $appsDir "$AppKey.json"

if (-not (Test-Path $appJson)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Application configuration for '$AppKey' was not found in $appsDir.",
        "App Locker Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}

$appData = Get-Content -Path $appJson -Raw | ConvertFrom-Json

# Helper: Compute Salted SHA-256 Hash
function Get-SaltedHash([string]$password, [byte[]]$saltBytes) {
    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $pwdBytes = [System.Text.Encoding]::UTF8.GetBytes($password)
    $combined = New-Object byte[] ($saltBytes.Length + $pwdBytes.Length)
    [Array]::Copy($saltBytes, 0, $combined, 0, $saltBytes.Length)
    [Array]::Copy($pwdBytes, 0, $combined, $saltBytes.Length, $pwdBytes.Length)
    $hashBytes = $hasher.ComputeHash($combined)
    return [BitConverter]::ToString($hashBytes).Replace('-', '').ToLower()
}

# Helper: Convert Hex String to Byte Array
function Convert-HexToBytes([string]$hex) {
    $bytes = New-Object byte[] ($hex.Length / 2)
    for ($i = 0; $i -lt $hex.Length; $i += 2) {
        $bytes[$i / 2] = [Convert]::ToByte($hex.Substring($i, 2), 16)
    }
    return $bytes
}

# Helper: Generate Random Salt
function Get-RandomSalt([int]$size = 16) {
    $salt = New-Object byte[] $size
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($salt)
    return $salt
}

# --- STEP 1: First-Run Master Password Setup Dialog ---
function Show-SetupMasterPasswordDialog {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "App Locker - Set Master Password"
    $form.Size = New-Object System.Drawing.Size(420, 290)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    $form.BackColor = [System.Drawing.Color]::FromArgb(32, 32, 32)
    $form.ForeColor = [System.Drawing.Color]::White

    $fontRegular = New-Object System.Drawing.Font("Segoe UI", 9.5)
    $fontBold = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", 8.5)

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Create Your Master Password"
    $lblTitle.Font = $fontBold
    $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 15)
    $lblTitle.Size = New-Object System.Drawing.Size(360, 25)
    $form.Controls.Add($lblTitle)

    $lblSubtitle = New-Object System.Windows.Forms.Label
    $lblSubtitle.Text = "This master password will protect all locked apps on your PC."
    $lblSubtitle.Font = $fontSmall
    $lblSubtitle.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
    $lblSubtitle.Location = New-Object System.Drawing.Point(20, 40)
    $lblSubtitle.Size = New-Object System.Drawing.Size(360, 20)
    $form.Controls.Add($lblSubtitle)

    $lblP1 = New-Object System.Windows.Forms.Label
    $lblP1.Text = "Master Password:"
    $lblP1.Font = $fontRegular
    $lblP1.Location = New-Object System.Drawing.Point(20, 70)
    $lblP1.Size = New-Object System.Drawing.Size(360, 20)
    $form.Controls.Add($lblP1)

    $txtP1 = New-Object System.Windows.Forms.TextBox
    $txtP1.Font = $fontRegular
    $txtP1.UseSystemPasswordChar = $true
    $txtP1.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $txtP1.ForeColor = [System.Drawing.Color]::White
    $txtP1.BorderStyle = "FixedSingle"
    $txtP1.Location = New-Object System.Drawing.Point(20, 92)
    $txtP1.Size = New-Object System.Drawing.Size(360, 26)
    $form.Controls.Add($txtP1)

    $lblP2 = New-Object System.Windows.Forms.Label
    $lblP2.Text = "Confirm Master Password:"
    $lblP2.Font = $fontRegular
    $lblP2.Location = New-Object System.Drawing.Point(20, 125)
    $lblP2.Size = New-Object System.Drawing.Size(360, 20)
    $form.Controls.Add($lblP2)

    $txtP2 = New-Object System.Windows.Forms.TextBox
    $txtP2.Font = $fontRegular
    $txtP2.UseSystemPasswordChar = $true
    $txtP2.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $txtP2.ForeColor = [System.Drawing.Color]::White
    $txtP2.BorderStyle = "FixedSingle"
    $txtP2.Location = New-Object System.Drawing.Point(20, 147)
    $txtP2.Size = New-Object System.Drawing.Size(360, 26)
    $form.Controls.Add($txtP2)

    $lblErr = New-Object System.Windows.Forms.Label
    $lblErr.Font = $fontSmall
    $lblErr.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
    $lblErr.Location = New-Object System.Drawing.Point(20, 178)
    $lblErr.Size = New-Object System.Drawing.Size(360, 20)
    $form.Controls.Add($lblErr)

    $btnSave = New-Object System.Windows.Forms.Button
    $btnSave.Text = "Save & Unlock"
    $btnSave.Font = $fontRegular
    $btnSave.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $btnSave.ForeColor = [System.Drawing.Color]::White
    $btnSave.FlatStyle = "Flat"
    $btnSave.FlatAppearance.BorderSize = 0
    $btnSave.Location = New-Object System.Drawing.Point(155, 205)
    $btnSave.Size = New-Object System.Drawing.Size(120, 32)
    $form.Controls.Add($btnSave)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Font = $fontRegular
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $btnCancel.ForeColor = [System.Drawing.Color]::White
    $btnCancel.FlatStyle = "Flat"
    $btnCancel.FlatAppearance.BorderSize = 0
    $btnCancel.Location = New-Object System.Drawing.Point(285, 205)
    $btnCancel.Size = New-Object System.Drawing.Size(95, 32)
    $form.Controls.Add($btnCancel)

    $form.AcceptButton = $btnSave
    $form.CancelButton = $btnCancel

    $btnCancel.Add_Click({
        $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.Close()
    })

    $btnSave.Add_Click({
        $p1 = $txtP1.Text
        $p2 = $txtP2.Text

        if ([string]::IsNullOrWhiteSpace($p1)) {
            $lblErr.Text = "Password cannot be empty."
            return
        }
        if ($p1.Length -lt 4) {
            $lblErr.Text = "Password must be at least 4 characters."
            return
        }
        if ($p1 -cne $p2) {
            $lblErr.Text = "Passwords do not match."
            return
        }

        # Generate salt & hash
        $salt = Get-RandomSalt 16
        $hexSalt = [BitConverter]::ToString($salt).Replace('-', '').ToLower()
        $hash = Get-SaltedHash $p1 $salt

        if (-not (Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }
        Set-Content -Path $hashFile -Value "$hexSalt:$hash" -Force

        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    })

    return $form.ShowDialog()
}

# --- STEP 2: Main Unlock Dialog ---
function Show-UnlockDialog([string]$appName, [string]$hexSalt, [string]$storedHash) {
    $saltBytes = Convert-HexToBytes $hexSalt

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "App Locker - $appName"
    $form.Size = New-Object System.Drawing.Size(380, 230)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $form.ForeColor = [System.Drawing.Color]::White

    # Try extracting app icon
    try {
        if (Test-Path $appData.TargetPath) {
            $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($appData.TargetPath)
            if ($icon) { $form.Icon = $icon }
        }
    } catch { }

    $fontRegular = New-Object System.Drawing.Font("Segoe UI", 9.5)
    $fontBold = New-Object System.Drawing.Font("Segoe UI", 11.0, [System.Drawing.FontStyle]::Bold)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", 8.5)

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Locked: $appName"
    $lblTitle.Font = $fontBold
    $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 18)
    $lblTitle.Size = New-Object System.Drawing.Size(325, 25)
    $form.Controls.Add($lblTitle)

    $lblSubtitle = New-Object System.Windows.Forms.Label
    $lblSubtitle.Text = "Enter master password to unlock application:"
    $lblSubtitle.Font = $fontSmall
    $lblSubtitle.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
    $lblSubtitle.Location = New-Object System.Drawing.Point(20, 45)
    $lblSubtitle.Size = New-Object System.Drawing.Size(325, 20)
    $form.Controls.Add($lblSubtitle)

    $txtPwd = New-Object System.Windows.Forms.TextBox
    $txtPwd.Font = New-Object System.Drawing.Font("Segoe UI", 10.5)
    $txtPwd.UseSystemPasswordChar = $true
    $txtPwd.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $txtPwd.ForeColor = [System.Drawing.Color]::White
    $txtPwd.BorderStyle = "FixedSingle"
    $txtPwd.Location = New-Object System.Drawing.Point(20, 72)
    $txtPwd.Size = New-Object System.Drawing.Size(325, 28)
    $form.Controls.Add($txtPwd)

    $lblErr = New-Object System.Windows.Forms.Label
    $lblErr.Font = $fontSmall
    $lblErr.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
    $lblErr.Location = New-Object System.Drawing.Point(20, 105)
    $lblErr.Size = New-Object System.Drawing.Size(325, 20)
    $form.Controls.Add($lblErr)

    $btnUnlock = New-Object System.Windows.Forms.Button
    $btnUnlock.Text = "Unlock"
    $btnUnlock.Font = $fontRegular
    $btnUnlock.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $btnUnlock.ForeColor = [System.Drawing.Color]::White
    $btnUnlock.FlatStyle = "Flat"
    $btnUnlock.FlatAppearance.BorderSize = 0
    $btnUnlock.Location = New-Object System.Drawing.Point(145, 135)
    $btnUnlock.Size = New-Object System.Drawing.Size(100, 32)
    $form.Controls.Add($btnUnlock)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Font = $fontRegular
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $btnCancel.ForeColor = [System.Drawing.Color]::White
    $btnCancel.FlatStyle = "Flat"
    $btnCancel.FlatAppearance.BorderSize = 0
    $btnCancel.Location = New-Object System.Drawing.Point(255, 135)
    $btnCancel.Size = New-Object System.Drawing.Size(90, 32)
    $form.Controls.Add($btnCancel)

    $form.AcceptButton = $btnUnlock
    $form.CancelButton = $btnCancel

    $script:attempts = 0

    $btnCancel.Add_Click({
        $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.Close()
    })

    $btnUnlock.Add_Click({
        $inputPwd = $txtPwd.Text
        $computed = Get-SaltedHash $inputPwd $saltBytes

        if ($computed -ceq $storedHash) {
            $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.Close()
        } else {
            $script:attempts++
            if ($script:attempts -ge 5) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Too many failed unlock attempts. Application will not start.",
                    "App Locker",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
                $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                $form.Close()
                return
            }
            $lblErr.Text = "Incorrect password ($script:attempts/5). Try again."
            $txtPwd.Text = ""
            $txtPwd.Focus()
        }
    })

    return $form.ShowDialog()
}

# --- MAIN EXECUTION FLOW ---

# If master password does not exist yet, prompt to set it
if (-not (Test-Path $hashFile)) {
    $res = Show-SetupMasterPasswordDialog
    if ($res -ne [System.Windows.Forms.DialogResult]::OK) {
        exit 0
    }
}

# Read stored master hash
$hashContent = (Get-Content -Path $hashFile -Raw).Trim()
$parts = $hashContent -split ":"
if ($parts.Length -ne 2) {
    [System.Windows.Forms.MessageBox]::Show(
        "Master password file is invalid or corrupted. Please run Reset-Password.ps1.",
        "App Locker Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}

$hexSalt = $parts[0]
$storedHash = $parts[1]

$appName = if ($appData.DisplayName) { $appData.DisplayName } else { $AppKey }

$unlockResult = Show-UnlockDialog -appName $appName -hexSalt $hexSalt -storedHash $storedHash

if ($unlockResult -eq [System.Windows.Forms.DialogResult]::OK) {
    # Launch real target executable with preserved arguments and working directory
    $targetPath = $appData.TargetPath
    $argsList   = $appData.Arguments
    $workDir    = $appData.WorkingDirectory

    if ([string]::IsNullOrWhiteSpace($workDir) -or -not (Test-Path $workDir)) {
        $workDir = Split-Path -Parent $targetPath
    }

    try {
        if ([string]::IsNullOrWhiteSpace($argsList)) {
            Start-Process -FilePath $targetPath -WorkingDirectory $workDir
        } else {
            Start-Process -FilePath $targetPath -ArgumentList $argsList -WorkingDirectory $workDir
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to launch $appName`: $($_.Exception.Message)",
            "App Locker Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}
