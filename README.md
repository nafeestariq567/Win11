# Windows 11 Master Suite (`Win11`)

A centralized, forensic-grade engineering suite containing diagnostic repair toolkits, debloat pipelines, and power optimizations for Windows 11.

Curated and verified on an **Acer Predator Laptop (Windows 11 Pro 64-bit, Build `26300` / 24H2 GE release)**.

---

## 🧭 Repository Index & Quick Launch

| Toolkit | Description | Standalone Repo | 1-Liner Quick Fix |
|---|---|---|---|
| **[Taskbar Sleep Fix](taskbar-sleep-fix/)** | Fixes taskbar icons turning blank/invisible after system sleep on multi-GPU (Intel + NVIDIA) & mixed-refresh (144Hz + 60Hz) setups. | [Windows11-Taskbar-Sleep-Fix](https://github.com/nafeestariq567/Windows11-Taskbar-Sleep-Fix) | `irm https://raw.githubusercontent.com/nafeestariq567/Windows11-Taskbar-Sleep-Fix/main/Fix_Taskbar_Sleep_Icons.ps1 \| iex` |
| **[PIN Corruption Resolver](pin-fix/)** | Fixes recurring Windows Hello PIN unavailability (`0xD000A002`, Event ID 7002) triggered by 3-hour sleep-to-hibernate resume crashes. | [Windows11-PIN-Fix](https://github.com/nafeestariq567/Windows11-PIN-Fix) | `irm https://raw.githubusercontent.com/nafeestariq567/Windows11-PIN-Fix/main/Fix_Windows_Hello_PIN.ps1 \| iex` |
| **[Win11 Debloat Suite](debloat/)** | Modular, safety-first debloat pipeline: safety baseline, privacy/telemetry hardening, bloatware purge, and service optimization. | [Win11Debloat](https://github.com/nafeestariq567/Win11Debloat) | `irm https://raw.githubusercontent.com/nafeestariq567/Win11Debloat/main/Apply-Win11Debloat.ps1 \| iex` |

---

## 📁 Modules Breakdown

### 1. [Taskbar Sleep Fix (`taskbar-sleep-fix/`)](taskbar-sleep-fix/)
- **The Problem:** Upon waking Windows 11 from sleep, some application icons (Chrome, File Explorer, Brave, Slack, etc.) disappear or become invisible transparent boxes with tooltips.
- **Root Cause:** 
  - PCIe Link State Power Management (ASPM) set to Maximum Power Savings on AC power, causing the dedicated NVIDIA GPU to lag on wake.
  - DirectX Graphics Kernel watchdog triggers `LiveKernelEvent 141` (`VIDEO_ENGINE_TDR_TIMEOUT`).
  - DWM presentation swap chains drop XAML DirectComposition surfaces, leaving WinUI button icons in a `Collapsed` state until an interaction event (`WM_SETTEXT` or mouse click) forces a redraw.
  - Explorer icon cache databases (`iconcache*.db`) were 5 months out of date.
- **The Fix:**
  - Sets PCIe ASPM to `0` (Off) on AC power (eliminates TDR 141; preserves `2` on DC for 0 battery drain).
  - Wipes and rebuilds the Explorer icon cache databases.
  - Includes [`Refresh_Taskbar.cmd`](taskbar-sleep-fix/Refresh_Taskbar.cmd) for 1-click sub-second shell reloads.

### 2. [Windows Hello PIN Corruption Resolver (`pin-fix/`)](pin-fix/)
- **The Problem:** Lock screen recurrently rejects PIN with *"Something happened and your PIN isn't available. Click to set up your PIN again"* (`0xD000A002`). Settings cannot modify or remove the PIN.
- **Root Cause:**
  - Windows default power plan attempts an automated sleep-to-hibernate transition after 3 hours (`HIBERNATEIDLE = 10,800s`).
  - Laptop NVMe controller fails resume (`0xC0000225`), causing dirty kernel crash reboots (`Kernel-Power 41`).
  - The crash corrupts the TPM 2.0 unwrap authorization and the encrypted `Ngc` container keys on disk.
- **The Fix:**
  - Takes administrative ownership and purges damaged `Ngc` cryptographic containers.
  - Sets `HIBERNATEIDLE` to `0` (Never) on AC and DC to neutralize the crash trigger.
  - Launches clean PIN provisioning.

### 3. [Windows 11 Debloat Suite (`debloat/`)](debloat/)
- **Phase 1: Safety Baseline:** Creates System Restore Point, exports registry backups, and catalogs installed packages.
- **Phase 2: Privacy & Telemetry Hardening:** Disables diagnostic telemetry, Cortana, advertising ID, Feedback Hub, and telemetry scheduled tasks.
- **Phase 3: Bloatware Purge:** Safely uninstalls non-essential preinstalled UWP provisioned packages and OEM bloat.
- **Phase 4: UI & Service Optimization:** Re-aligns taskbar, disables background app resource hogs, and streamlines context menus. Full 1-click rollback scripts included.

---

## 🔗 Related Projects

- **Brave Browser Debloat:** [`https://github.com/nafeestariq567/BraveDebloat`](https://github.com/nafeestariq567/BraveDebloat) — Privacy hardening and telemetry removal for Brave Browser on Windows 11.

---

## 💻 Host System Architecture

- **Machine:** Acer Predator PH317-53 Laptop
- **OS:** Windows 11 Professional 64-bit (Build `26300` / 24H2)
- **CPU / Memory:** Intel Core i7-9750H @ 2.60GHz, 16 GB DDR4 RAM
- **Graphics 1 (Internal Panel @ 144 Hz):** Intel(R) UHD Graphics 630
- **Graphics 2 (External Display @ 60 Hz):** NVIDIA GeForce RTX 2070 with Max-Q Design
- **Security Hardware:** Intel Platform Trust Technology (TPM 2.0)
- **Power Configuration:** S3 Sleep with Hybrid Sleep disabled, Hibernate idle set to 0.
