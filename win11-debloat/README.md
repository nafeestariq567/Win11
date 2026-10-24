# Windows 11 Debloat Suite (Developer & Acer Predator Edition)

A modular, auditable, and fully reversible Windows 11 debloating suite tailored specifically for Software Engineers and Power Users on an Acer Predator Laptop (Windows 11 Pro 64-bit).

Benchmarked against the top industry debloaters: **Sophia Script for Windows 11**, **Chris Titus WinUtil**, and **O&O ShutUp10++**.

---

## ⚡ Instant Install (PowerShell One-Liner)

To apply this entire debloat configuration on any fresh Windows install in seconds without cloning the repository, open **PowerShell as Administrator** and paste:

```powershell
irm https://raw.githubusercontent.com/nafeestariq567/Win11/main/win11-debloat/Apply-Win11Debloat.ps1 | iex
```

---

## 1. Guiding Principles & Hardware Safeguards

1. **Zero Regrets & Zero Hardware Risk:**
   - **Acer Predator Hardware Utilities:** `PredatorSense`, `AcerCareCenter`, and `QuickAccess` are 100% safeguarded. GPU overclocking, fan curves, keyboard lighting, and power modes remain untouched.
   - **Motherboard WPBT:** Kept default to ensure zero boot or firmware friction.
   - **Location Services:** Kept enabled for time zones, maps, and browser localization.
2. **Developer-First Experience:**
   - **Windows Dev Home:** Kept intact for GitHub dashboards and WSL/Dev Drive environments.
   - **Windows Terminal, PowerShell, & WSL:** Preserved 100%.
   - **Productivity Essentials:** Clock/Stopwatch/Timer, Camera, Clipchamp, Sound Recorder, Phone Link, and Xbox Game Bar (`Win+G` screen recording) are kept.
   - **Explorer Tweaks:** File extensions (`.exe`, `.ps1`, `.js`) and hidden files/folders (`AppData`, `.env`, `.git`) are made visible.
3. **100% Auditable & Reversible:**
   - Every modification is backed by a matching 1:1 rollback script.
   - Preceded by a kernel System Restore Point (`Checkpoint-Computer`) and baseline registry backups.
4. **Zero Silent or Unapproved Decisions (Strict Transparency Mandate):**
   > [!IMPORTANT]
   > Under no circumstances should any script, assistant, or future contributor make silent assumptions or unapproved removals. If any package, service, scheduled task, or Windows setting is discovered on the system that is not explicitly approved for removal/modification in this repository, it **MUST** be discussed with the user first with a clear 1-line description of what it does, and explicit permission must be granted before touching it. No "dumb hidden decisions."

---

## 2. 1-Click Execution Launchers (Local Clone)

For maximum convenience, all scripts are also wrapped with self-elevating `.cmd` launchers:

| Action | 1-Click Launcher | PowerShell Script | Rollback Script |
|---|---|---|---|
| **Full Debloat (All Steps)** | [`Run_All_Debloat_Admin.cmd`](file:///C:/Debloat%20Windows%2011/Run_All_Debloat_Admin.cmd) | [`Run_All_Debloat.ps1`](file:///C:/Debloat%20Windows%2011/Run_All_Debloat.ps1) | [`Run_All_Restore.ps1`](file:///C:/Debloat%20Windows%2011/Run_All_Restore.ps1) |
| **Step 1: Safety Baseline** | [`Run_Step1_Baseline_Admin.cmd`](file:///C:/Debloat%20Windows%2011/Run_Step1_Baseline_Admin.cmd) | [`01_Create_Safety_Baseline.ps1`](file:///C:/Debloat%20Windows%2011/01_Create_Safety_Baseline.ps1) | *Windows Recovery / Restore Point* |
| **Step 2: Privacy & Ads** | [`Run_Step2_Privacy_Admin.cmd`](file:///C:/Debloat%20Windows%2011/Run_Step2_Privacy_Admin.cmd) | [`02_Apply_Privacy_And_Ads_Hardening.ps1`](file:///C:/Debloat%20Windows%2011/02_Apply_Privacy_And_Ads_Hardening.ps1) | [`02_Restore_Privacy_And_Ads_Defaults.ps1`](file:///C:/Debloat%20Windows%2011/02_Restore_Privacy_And_Ads_Defaults.ps1) |
| **Step 3: Bloatware Removal** | [`Run_Step3_Bloatware_Admin.cmd`](file:///C:/Debloat%20Windows%2011/Run_Step3_Bloatware_Admin.cmd) | [`03_Remove_Bloatware_Apps.ps1`](file:///C:/Debloat%20Windows%2011/03_Remove_Bloatware_Apps.ps1) | [`03_Reinstall_Bloatware_Apps.ps1`](file:///C:/Debloat%20Windows%2011/03_Reinstall_Bloatware_Apps.ps1) |
| **Step 4: UI, Power & Services** | [`Run_Step4_UI_Services_Admin.cmd`](file:///C:/Debloat%20Windows%2011/Run_Step4_UI_Services_Admin.cmd) | [`04_Apply_UI_And_Services.ps1`](file:///C:/Debloat%20Windows%2011/04_Apply_UI_And_Services.ps1) | [`04_Restore_UI_And_Services.ps1`](file:///C:/Debloat%20Windows%2011/04_Restore_UI_And_Services.ps1) |

---

## 3. Detailed Step Breakdown

### Step 1: Safety Baseline & Restore Point
- Sets `SystemRestorePointCreationFrequency = 0` to bypass the 24-hour limit.
- Enables System Protection on `C:\`.
- Creates Restore Point: `"Pre-Debloat Baseline (Clean State)"`.
- Exports baseline registry hives and inventories all 153 installed AppX packages to [`Backups/`](file:///C:/Debloat%20Windows%2011/Backups).

### Step 2: Privacy, Telemetry, Inking & Ads Hardening
- **Diagnostic Telemetry:** Set to minimal/security level via Group Policy (`AllowTelemetry = 0/1`, `MaxTelemetryAllowed = 1`, `CEIPEnable = 0`).
- **Inking & Typing:** Keystroke logging and dictionary harvesting disabled (`HarvestContacts = 0`).
- **AI Telemetry:** Recall snapshot telemetry disabled; Copilot app remains accessible.
- **Search:** Bing web search and dynamic search highlights disabled (instant local file/app search).
- **Consumer Ads:** `ContentDeliveryManager` silent app installs, lockscreen tips, and Start recommendations disabled.
- **Network & Maintenance:** Delivery Optimization P2P upload seeding disabled; 5 telemetry scheduled tasks disabled (`Compatibility Appraiser`, `Consolidator`, `UsbCeip`); leftover `OneDriveSetup` startup trigger purged.

### Step 3: Curated Bloatware Removal (13 Packages)
Removes for the current user and deprovisions from the OS image:
1. `Microsoft.GamingApp` (Xbox PC app - Game Bar screen recording `Win+G` is kept)
2. `Microsoft.MicrosoftOfficeHub` (365 promo hub)
3. `Microsoft.BingNews` (MSN News)
4. `Microsoft.BingWeather` (MSN Weather)
5. `Microsoft.MicrosoftSolitaireCollection` (Solitaire card games)
6. `Microsoft.Todos` (Microsoft To-Do)
7. `Microsoft.WindowsFeedbackHub` (Feedback Hub)
8. `Microsoft.GetHelp` (Get Help automated troubleshooter)
9. `MicrosoftCorporationII.QuickAssist` (Quick Assist remote tool)
10. `Microsoft.PowerAutomateDesktop` (Power Automate)
11. `Microsoft.People` (Legacy contacts address book)
12. `Microsoft.MicrosoftStickyNotes` (Sticky Notes)
13. `Microsoft.ZuneMusic` (Modern Media Player)

### Step 4: UI, Taskbar, Edge Startup & Services
- **File Explorer:** Shows known file extensions (`HideFileExt = 0`), shows hidden files & folders (`Hidden = 1`), disables network auto-discovery lag (`NoNetCrawling = 1`).
- **Taskbar:** Enables "End Task" on right-click (`TaskbarEndTask = 1`), hides Chat/Teams icon (`TaskbarMn = 0`), hides Widgets (`TaskbarDa = 0` and removes `WebExperience`), keeps icons Centered.
- **Snappy UI:** Sets `MenuShowDelay = 150` for instant submenu response.
- **Edge Overhead:** Disables Edge Startup Boost and background extensions (`StartupBoostEnabled = 0`, `BackgroundModeEnabled = 0`).
- **Sleep Protection:** Disables sleep wake timers to prevent laptop overheating in a backpack.
- **Services:** Sets `DiagTrack` and `dmwappushservice` to Manual and stops them.

---

## 4. Reversal & Rollback (Zero Regrets Guarantee)

Every single setting has an exact 1:1 rollback:
- **Full Rollback:** Run [`Run_All_Restore_Admin.cmd`](file:///C:/Debloat%20Windows%2011/Run_All_Restore_Admin.cmd) to revert all policies, UI tweaks, power settings, and services back to factory defaults.
- **App Reinstallation:** Run `powershell -ExecutionPolicy Bypass -File .\03_Reinstall_Bloatware_Apps.ps1` to automatically reinstall all 13 removed apps via `winget` / Microsoft Store.
