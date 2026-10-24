# Windows 11 Debloat: Technical Reference & Implementation Roadmap

This document serves as the technical reference manual for executing Windows 11 debloating. All registry policies, Group Policies, AppX package IDs, and service states are documented here.

---

## 1. Safety & Baseline Setup

### 1.1 Enable & Create System Restore Point
```powershell
# Ensure System Protection is enabled on C:
Enable-ComputerRestore -Drive "C:\"

# Create a clean baseline restore point
Checkpoint-Computer -Description "Pre-Debloat Baseline (Clean State)" -RestorePointType "MODIFY_SETTINGS"
```

### 1.2 Export Baseline Registry Keys
```powershell
$backupDir = "C:\Debloat Windows 11\Backups"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows" "$backupDir\HKLM_Policies_Windows_Baseline.reg" /y
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "$backupDir\HKCU_ContentDeliveryManager_Baseline.reg" /y
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" "$backupDir\HKCU_Search_Baseline.reg" /y
```

---

## 2. Telemetry & Diagnostic Data (Group Policy / HKLM)

Windows 11 Professional fully enforces these enterprise policies under `HKLM\SOFTWARE\Policies\Microsoft\Windows`:

| Setting / Policy | Registry Path | Name | Type | Value (Disabled) |
|---|---|---|---|---|
| **Telemetry Level** | `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowTelemetry` | DWORD | `0` (Security/Off on Pro/Ent) or `1` (Basic) |
| **Max Telemetry Allowed** | `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `MaxTelemetryAllowed` | DWORD | `1` |
| **Disable CEIP** | `HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows` | `CEIPEnable` | DWORD | `0` |
| **Disable Feedback Prompts** | `HKCU:\SOFTWARE\Microsoft\Siuf\Rules` | `NumberOfSIUFInPeriod` | DWORD | `0` |
| **Disable Advertising ID** | `HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo` | `DisabledByGroupPolicy` | DWORD | `1` |
| **Disable Activity History** | `HKLM:\SOFTWARE\Policies\Microsoft\Windows\System` | `EnableActivityFeed` | DWORD | `0` |
| **Disable Upload User Activities** | `HKLM:\SOFTWARE\Policies\Microsoft\Windows\System` | `PublishUserActivities` | DWORD | `0` |
| **Disable Location Sensor** | `HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors` | `DisableLocation` | DWORD | `1` |

---

## 3. Consumer Promoted Apps & Start Menu Ads

Microsoft uses the `ContentDeliveryManager` to push sponsored apps, lockscreen ads, and suggestions.

| Setting | Registry Path | Name | Type | Value |
|---|---|---|---|---|
| **Silent App Installs** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` | `SilentInstalledAppsEnabled` | DWORD | `0` |
| **Start Suggestions** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` | `SystemPaneSuggestionsEnabled` | DWORD | `0` |
| **Lock Screen Tips** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` | `RotatingLockScreenOverlayEnabled` | DWORD | `0` |
| **Subscribed Content Ads** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` | `SubscribedContent-338388Enabled` | DWORD | `0` |
| **Settings App Ads** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` | `SubscribedContent-338389Enabled` | DWORD | `0` |
| **Welcome Experience** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` | `SubscribedContent-310093Enabled` | DWORD | `0` |
| **Disable Cloud Optimized Content** | `HKCU:\Software\Policies\Microsoft\Windows\CloudContent` | `DisableWindowsConsumerFeatures` | DWORD | `1` |

---

## 4. Search & Taskbar / Shell Enhancements

| Feature | Registry Path | Name | Type | Value |
|---|---|---|---|---|
| **Disable Bing in Search** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\Search` | `BingSearchEnabled` | DWORD | `0` |
| **Disable Cortana/Web Consent** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\Search` | `CortanaConsent` | DWORD | `0` |
| **Disable Search Box Suggestions** | `HKCU:\Software\Policies\Microsoft\Windows\Explorer` | `DisableSearchBoxSuggestions` | DWORD | `1` |
| **Disable Search Highlights** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings` | `IsDynamicSearchBoxEnabled` | DWORD | `0` |
| **Enable End Task on Taskbar** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings` | `TaskbarEndTask` | DWORD | `1` |
| **Disable Taskbar Widgets** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced` | `TaskbarDa` | DWORD | `0` |
| **Disable Taskbar Chat** | `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced` | `TaskbarMn` | DWORD | `0` |
| **Disable Copilot** | `HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot` | `TurnOffWindowsCopilot` | DWORD | `1` |
| **Classic Windows 10 Context Menu** | `HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32` | `(Default)` | String | `""` (empty string) |

---

## 5. Background Services & Tasks Optimization

### 5.1 Non-Essential Services (Set to Manual)
- `DiagTrack` (Connected User Experiences and Telemetry)
- `dmwappushservice` (Device Management Wireless Application Protocol Push message Routing Service)
- `diagnosticshub.standardcollector.service` (Microsoft Diagnostics Hub Standard Collector)
- `MapsBroker` (Downloaded Maps Manager - unnecessary unless using offline Bing maps)

```powershell
$services = @("DiagTrack", "dmwappushservice", "diagnosticshub.standardcollector.service", "MapsBroker")
foreach ($svc in $services) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Manual
    }
}
```

### 5.2 Scheduled Telemetry Tasks (Disable)
- `\Microsoft\Windows\Customer Experience Improvement Program\Consolidator`
- `\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip`
- `\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser`
- `\Microsoft\Windows\Application Experience\ProgramDataUpdater`
- `\Microsoft\Windows\Autochk\Proxy`

```powershell
$tasks = @(
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy"
)
foreach ($task in $tasks) {
    Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
}
```

---

## 6. UWP Bloatware Removal Strategy

### 6.1 Safe Removal Pattern
```powershell
# Remove from current user profile
Get-AppxPackage -Name "*<AppName>*" | Remove-AppxPackage -ErrorAction SilentlyContinue

# Deprovision so it never installs for new user profiles
Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*<AppName>*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
```

### 6.2 Common Bloatware Package Patterns
- `*Clipchamp.Clipchamp*`
- `*Microsoft.BingNews*`
- `*Microsoft.BingWeather*`
- `*Microsoft.GetHelp*`
- `*Microsoft.Getstarted*` (Tips)
- `*Microsoft.MicrosoftOfficeHub*`
- `*Microsoft.MicrosoftSolitaireCollection*`
- `*Microsoft.People*`
- `*Microsoft.PowerAutomateDesktop*`
- `*Microsoft.Todos*`
- `*Microsoft.WindowsFeedbackHub*`
- `*Microsoft.WindowsMaps*`
- `*Microsoft.YourPhone*` (Phone Link - optional)
- `*Microsoft.Xbox*` / `*Microsoft.GamingApp*` (Optional based on checklist)

---

## 7. Reversibility & Rollback

Every script implemented in this project must be mirrored by an equivalent restore script:
- `Apply-PrivacyHardening.ps1` ↔ `Restore-PrivacyDefaults.ps1`
- `Apply-ShellTweaks.ps1` ↔ `Restore-ShellDefaults.ps1`
- `Remove-BloatwareApps.ps1` ↔ `Reinstall-BloatwareApps.ps1` (via Microsoft Store / Winget)
- `Windows11_Debloat.reg` ↔ `Windows11_Restore.reg`
