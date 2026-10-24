# Module Quick Start: Taskbar Sleep Icon Fix (`taskbar-sleep-fix/`)

This module contains the diagnostic context, forensic root cause breakdown, and automated repair scripts for resolving taskbar icons turning blank/invisible upon waking from sleep.

> [!TIP]
> Global host architecture and verified system specs are maintained in the root file: [`../SYSTEM_SPECS.md`](../SYSTEM_SPECS.md).
> AI Agent operating protocols are in: [`../START_HERE.md`](../START_HERE.md).

---

## 1. Quick Launch (One-Liner)

```powershell
irm https://raw.githubusercontent.com/nafeestariq567/Win11/main/taskbar-sleep-fix/Fix_Taskbar_Sleep_Icons.ps1 | iex
```

---

## 2. File Index

- [`README.md`](README.md) — Comprehensive technical documentation, forensic analysis, and 1-liner install command.
- [`Fix_Taskbar_Sleep_Icons.ps1`](Fix_Taskbar_Sleep_Icons.ps1) — Core PowerShell repair script (PCIe ASPM fix + icon cache purge).
- [`Refresh_Taskbar.cmd`](Refresh_Taskbar.cmd) — Instant 1-second shell reload launcher.
- [`assets/`](assets/) — Visual evidence from host displays and community reports.
