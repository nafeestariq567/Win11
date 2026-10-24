# Windows 11 Debloat: Preferences Checklist (Complete, Benchmarked & Verified)

Last updated: October 21, 2026.
Tailored specifically for a Software Engineer / Power User on an Acer Predator Laptop (Windows 11 Pro 26H2).
Benchmarked against Sophia Script, Chris Titus WinUtil, and O&O ShutUp10++.

> [!IMPORTANT]
> **Core Mandate: Zero Silent or Unapproved Decisions**
> If an assistant or script encounters any package, background service, or setting not explicitly listed below, it **MUST NOT** make assumptions or remove anything silently. It must describe what that component does in one clear line, discuss it with the user, and obtain explicit permission first. No dumb hidden decisions.

---

### 1. Developer & Core Productivity Tools (100% Intact & Protected)
- [x] **KEEP Windows Dev Home** (`Microsoft.Windows.DevHome` - Dev dashboard, GitHub widgets, WSL/Dev Drive integration).
- [x] **KEEP Windows Terminal** (`Microsoft.WindowsTerminal`).
- [x] **KEEP Windows Clock & Alarms** (`Microsoft.WindowsAlarms` - Timers, stopwatch, alarms).
- [x] **KEEP Windows Camera** (`Microsoft.WindowsCamera` - Webcam preview for meetings).
- [x] **KEEP Clipchamp** (`Clipchamp.Clipchamp` - Quick video trimming/editing).
- [x] **KEEP Sound Recorder** (`Microsoft.WindowsSoundRecorder` - Voice recordings).
- [x] **KEEP Phone Link** (`Microsoft.YourPhone` - Mobile device sync).
- [x] **KEEP Xbox Game Bar** (`Microsoft.XboxGamingOverlay` - Win+G screen recording).
- [x] **KEEP Core System Utilities** (`Notepad`, `Calculator`, `Paint`, `Snipping Tool`, `Photos`, `Store`, `Winget`).
- [x] **KEEP Acer Predator Hardware Utilities** (`PredatorSense`, `AcerCareCenter`, `QuickAccess` - Thermals, fans, lighting).
- [x] **KEEP Personal & Dev Apps** (`Claude`, `Slack`, `WhatsApp`, `KDE Connect`, `NanaZip`, `PowerToys`).

---

### 2. Location & Hardware Safety (Zero Regrets)
- [x] **KEEP Location Services ENABLED** (Location sensors and `MapsBroker` untouched for time zones, maps, and browser localization).
- [x] **KEEP WPBT Motherboard Firmware Execution DEFAULT** (Untouched to eliminate any hardware or startup risk).

---

### 3. File Explorer & Taskbar Tweaks
- [x] **KEEP Windows 10 Classic Right-Click Menu** (Already active, preserved untouched).
- [x] **KEEP Taskbar Alignment Centered** (Icons stay centered per user preference).
- [x] **SHOW Known File Extensions** (`HideFileExt = 0` - reveals `.exe`, `.ps1`, `.js`, `.py`, etc.).
- [x] **SHOW Hidden Files & Folders** (`Hidden = 1` - reveals `.env`, `.git`, `.ssh`, `AppData` for dev work).
- [x] **DISABLE File Explorer Network Auto-Discovery** (`NoNetCrawling = 1` - eliminates folder loading lag).
- [x] **ENABLE "End Task" on Taskbar Right-Click** (`TaskbarEndTask = 1` - instant force-quit for frozen apps).
- [x] **HIDE Taskbar Chat / Teams Icon** (`TaskbarMn = 0`).
- [x] **DISABLE Taskbar Widgets / MSN Feed** (`TaskbarDa = 0` and deprovision `WebExperience`).
- [x] **REDUCE MenuShowDelay to 150ms** (`MenuShowDelay = 150` - snappy submenus with zero lag).

---

### 4. Search, AI & Telemetry Hardening
- [x] **KEEP Windows Copilot Available** (Copilot app and chat remain accessible).
- [x] **DISABLE Background Recall & AI Telemetry** (Blocks automatic screenshot analysis and AI diagnostic tracking).
- [x] **DISABLE Bing in Start Menu** (Instant, private, local-only file/app search).
- [x] **DISABLE Search Highlights & Trending Content** (Removes rotating cartoons, trivia, and web fluff).
- [x] **SET Diagnostic Telemetry to Minimum / Security Level** (`AllowTelemetry = 0/1` via Group Policy).
- [x] **DISABLE Inking & Typing Telemetry** (`HarvestContacts = 0` - stops keystroke/dictionary harvesting).
- [x] **DISABLE Advertising ID** (`DisabledByGroupPolicy = 1`).
- [x] **DISABLE Activity History & Timeline Cloud Sync** (`EnableActivityFeed = 0`).
- [x] **DISABLE Delivery Optimization P2P Sharing** (`DODownloadMode = 1/0` - no upload bandwidth seeding).
- [x] **SET DiagTrack & Diagnostic Services to Manual & Stop** (Saves background CPU and RAM).
- [x] **DISABLE Telemetry Scheduled Tasks** (Stops `Compatibility Appraiser`, `Consolidator`, `UsbCeip`; local Event Viewer and crash logs stay 100% active).
- [x] **STOP Edge Background Processes & Startup Boost** (Stops `msedge.exe` from pre-launching at boot; saves 150-300MB RAM).
- [x] **DISABLE Sleep Wake Timers** (Prevents laptop from waking up in backpack; wakes only on lid open or key press).
- [x] **PURGE Leftover OneDrive Startup Stub** (`HKCU:...\Run\OneDriveSetup.exe`).

---

### 5. Consumer Bloat & Ads Elimination
- [x] **DISABLE Content Delivery Manager Promos** (Blocks silent background downloads of sponsored apps like TikTok, Disney+, etc.).
- [x] **DISABLE Start Menu app recommendations & tips**.
- [x] **DISABLE Lock Screen tips, fun facts, and ads**.
- [x] **DISABLE Settings app suggested content and promotional banners**.

---

### 6. Curated UWP Bloatware Removal List (13 Packages)
*(All packages removable safely for current user and deprovisioned for new profiles. Can be reinstalled from Microsoft Store anytime)*:
1. `Microsoft.GamingApp` (Xbox PC App storefront)
2. `Microsoft.MicrosoftOfficeHub` (Microsoft 365 promo hub)
3. `Microsoft.BingNews` (MSN News)
4. `Microsoft.BingWeather` (MSN Weather)
5. `Microsoft.MicrosoftSolitaireCollection` (Solitaire games with ads)
6. `Microsoft.Todos` (Microsoft To-Do)
7. `Microsoft.WindowsFeedbackHub` (Feedback Hub)
8. `Microsoft.GetHelp` (Get Help automated troubleshooter)
9. `MicrosoftCorporationII.QuickAssist` (Quick Assist remote tool)
10. `Microsoft.PowerAutomateDesktop` (Power Automate)
11. `Microsoft.People` (Legacy contacts address book)
12. `Microsoft.MicrosoftStickyNotes` (Sticky Notes)
13. `Microsoft.ZuneMusic` (Modern Media Player)
*(Taskbar Widgets package `MicrosoftWindows.Client.WebExperience` handled in UI tweaks)*
