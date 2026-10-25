# Windows 11 Master Suite (`Win11`)

A centralized, forensic-grade engineering repository containing all diagnostic repairs, debloat pipelines, and system optimizations for Windows 11 maintained by **nafeestariq567**.

---

## 🧭 Repository Index & Quick Launch

| Module | Description | 1-Liner Quick Fix / Run Command |
|---|---|---|
| **[`taskbar-sleep-fix/`](taskbar-sleep-fix/)** | Fixes taskbar icons turning blank/invisible after system sleep on multi-GPU (Intel + NVIDIA) & mixed-refresh (144Hz + 60Hz) setups. | `irm https://raw.githubusercontent.com/nafeestariq567/Win11/main/taskbar-sleep-fix/Fix_Taskbar_Sleep_Icons.ps1 \| iex` |
| **[`pin-fix/`](pin-fix/)** | Fixes recurring Windows Hello PIN unavailability (`0xD000A002`, Event ID 7002) triggered by 3-hour sleep-to-hibernate resume crashes. | `irm https://raw.githubusercontent.com/nafeestariq567/Win11/main/pin-fix/Fix_Windows_Hello_PIN.ps1 \| iex` |
| **[`win11-debloat/`](win11-debloat/)** | Modular, safety-first debloat pipeline: safety baseline, privacy/telemetry hardening, bloatware purge, and service optimization. | `irm https://raw.githubusercontent.com/nafeestariq567/Win11/main/win11-debloat/Apply-Win11Debloat.ps1 \| iex` |
| **[`brave-debloat/`](brave-debloat/)** | Privacy-first debloater and telemetry hardener for Brave and Brave Beta on Windows 11. | `irm https://raw.githubusercontent.com/nafeestariq567/Win11/main/brave-debloat/Apply-BraveDebloat.ps1 \| iex` |
| **[`app-locker/`](app-locker/)** | Universal Desktop App Locker: password-protects any desktop app shortcut (e.g. Brave Beta) with salted SHA-256 master password dialog. | `powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Win11\app-locker\Lock-App.ps1"` |

---

## 🏗️ Repository Architecture & Design Philosophy

This repository is organized to serve as the **single home** for any Windows 11 task on this PC:

```text
C:\Win11\
├── README.md                          # Master catalog, 1-liner commands, and architecture
├── START_HERE.md                      # AI Agent Operating Protocol & Task Router
├── SYSTEM_SPECS.md                    # Single Source of Truth for verified hardware & OS
│
├── taskbar-sleep-fix/                 # Taskbar Sleep Icon Disappearance Resolver
│   ├── README.md                      # Forensic analysis, TDR 141 breakdown & instructions
│   ├── Fix_Taskbar_Sleep_Icons.ps1    # Automated repair script
│   ├── Refresh_Taskbar.cmd            # 1-click sub-second shell reload launcher
│   ├── START_HERE.md                  # Module quick start
│   └── assets/                        # Multi-monitor & community bug screenshots
│
├── pin-fix/                           # Windows Hello PIN Corruption Resolver
│   ├── README.md                      # Event 7002 & 3-hour hibernate crash breakdown
│   ├── Fix_Windows_Hello_PIN.ps1      # Automated cryptographic key & power repair script
│   ├── Run_Fix_PIN_Admin.cmd          # Self-elevating 1-click execution wrapper
│   ├── CONTEXT_AND_TRANSCRIPT.md      # Deep technical investigation history
│   ├── START_HERE.md                  # Module quick start
│   └── assets/                        # Original error photo
│
├── win11-debloat/                     # Windows 11 Master Debloat Suite
│   ├── README.md                      # Guiding principles, phase breakdown & documentation
│   ├── Apply-Win11Debloat.ps1         # 1-liner all-in-one debloat runner
│   ├── 01_Create_Safety_Baseline.ps1  # Restore point & registry export
│   ├── 02_Apply_Privacy_And_Ads_Hardening.ps1 # Telemetry & ad disablement
│   ├── 03_Remove_Bloatware_Apps.ps1   # Provisioned AppX purge
│   ├── 04_Apply_UI_And_Services.ps1   # Background service & UI optimizer
│   ├── Run_All_Restore_Admin.cmd      # Complete 1-click restore wrapper
│   └── Backups/                       # Pre-debloat system state backups
│
├── brave-debloat/                     # Brave Browser Debloat Suite
│   ├── README.md                      # Policy breakdown & user choices
│   ├── Apply-BraveDebloat.ps1         # Policy enforcer script
│   ├── BraveDebloat.reg               # Direct registry policy tweaks
│   ├── BraveRestore.reg               # Full restoration registry file
│   └── Run-Debloat.cmd                # 1-click execution wrapper
│
└── app-locker/                        # Universal Desktop App Locker
    ├── README.md                      # Architecture & usage instructions
    ├── START_HERE.md                  # Module quick start
    ├── AppLocker.cs                   # C# source code for native Windows GUI gatekeeper
    ├── AppLocker.exe                  # Compiled native Windows GUI executable (/target:winexe)
    ├── Lock-App.ps1                   # Shortcut inspector & locker
    ├── Unlock-App.ps1                 # 1-click shortcut restorer
    ├── Reset-Password.ps1             # Master password manager
    ├── config/                        # Salted SHA-256 master hash
    └── apps/                          # App profiles & backup .lnk files
```

### Separation of Concerns:
1. **Root Level (`C:\Win11\`):** Holds global specifications ([`SYSTEM_SPECS.md`](SYSTEM_SPECS.md)), the AI Agent Router ([`START_HERE.md`](START_HERE.md)), and master catalog ([`README.md`](README.md)).
2. **Subfolder Level (`C:\Win11\<module>\`):** Every module is completely self-contained with its own executable scripts, documentation, and assets.
3. **Adding New Tasks:** Any future Windows 11 task that does not fit into existing modules gets its own clean subfolder inside `C:\Win11/`, keeping the root organized.

---

## 💻 Verified Host Hardware & OS Profile

Full specifications are maintained in [`SYSTEM_SPECS.md`](SYSTEM_SPECS.md):

- **Device:** Acer Predator PH317-53 Laptop (`DESKTOP-7LV0LO3`)
- **OS:** Windows 11 Pro 64-bit, Version **26H2**, Build **`26300.9711`** (Experience Pack `1000.26100.372.0`)
- **Processor:** Intel Core i7-9750H @ 2.60GHz (6 Cores, 12 Threads)
- **RAM:** **32.0 GB** (31.8 GB usable) @ 2667 MHz
- **Dedicated GPU:** NVIDIA GeForce RTX 2070 with Max-Q Design (8 GB VRAM)
- **Integrated GPU:** Intel UHD Graphics 630 (128 MB VRAM)
- **Storage:** 1.38 TB NVMe SSD (939 GB used)
- **Displays:**
  - Display 1: Internal 17.3" Panel (`AUO409D`) @ **144 Hz** (Intel iGPU)
  - Display 2: External Lenovo Monitor (`LEN60A8`) @ **60 Hz** (NVIDIA dGPU)
