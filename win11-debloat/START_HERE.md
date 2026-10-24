# Module Quick Start: Windows 11 Debloat Suite (`win11-debloat/`)

This module contains the 4-phase debloat pipeline, privacy hardening routines, provisioned AppX bloatware uninstaller, and safety rollback scripts.

> [!TIP]
> Global host architecture and verified system specs are maintained in the root file: [`../SYSTEM_SPECS.md`](../SYSTEM_SPECS.md).
> AI Agent operating protocols are in: [`../START_HERE.md`](../START_HERE.md).

---

## 1. Quick Launch (One-Liner)

```powershell
irm https://raw.githubusercontent.com/nafeestariq567/Win11/main/win11-debloat/Apply-Win11Debloat.ps1 | iex
```

---

## 2. File Index

- [`README.md`](README.md) — Guiding principles, phase breakdown, and safety procedures.
- [`Apply-Win11Debloat.ps1`](Apply-Win11Debloat.ps1) — All-in-one debloat runner.
- [`01_Create_Safety_Baseline.ps1`](01_Create_Safety_Baseline.ps1) — System restore point & registry backup.
- [`02_Apply_Privacy_And_Ads_Hardening.ps1`](02_Apply_Privacy_And_Ads_Hardening.ps1) — Telemetry & advertising ID disablement.
- [`03_Remove_Bloatware_Apps.ps1`](03_Remove_Bloatware_Apps.ps1) — Safe UWP bloatware removal.
- [`04_Apply_UI_And_Services.ps1`](04_Apply_UI_And_Services.ps1) — Background services and taskbar streamlining.
- [`Run_All_Restore_Admin.cmd`](Run_All_Restore_Admin.cmd) — Complete 1-click rollback launcher.
- [`Backups/`](Backups/) — Pre-debloat system state and registry exports.
