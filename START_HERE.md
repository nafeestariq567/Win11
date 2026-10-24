# Start Here: Windows 11 Master Suite (`Win11`)

Welcome to the **Windows 11 Master Suite (`Win11`)**. This repository consolidates all diagnostic repairs, forensic problem solvers, and system debloat modules maintained by **nafeestariq567**.

---

## 1. Quick Navigation

- [`README.md`](README.md) — Main index, problem statements, and 1-liner PowerShell quick fixes.
- [`taskbar-sleep-fix/`](taskbar-sleep-fix/) — Standalone toolkit for the Taskbar Sleep Icon Disappearance bug.
  - Standalone GitHub: [`https://github.com/nafeestariq567/Windows11-Taskbar-Sleep-Fix`](https://github.com/nafeestariq567/Windows11-Taskbar-Sleep-Fix)
- [`pin-fix/`](pin-fix/) — Standalone toolkit for the Windows Hello PIN corruption bug (`0xD000A002`).
  - Standalone GitHub: [`https://github.com/nafeestariq567/Windows11-PIN-Fix`](https://github.com/nafeestariq567/Windows11-PIN-Fix)
- [`win11-debloat/`](win11-debloat/) — Standalone modular debloat and telemetry hardening pipeline.
  - Standalone GitHub: [`https://github.com/nafeestariq567/Win11Debloat`](https://github.com/nafeestariq567/Win11Debloat)
- [`brave-debloat/`](brave-debloat/) — Privacy-first debloater and telemetry hardener for Brave Browser.
  - Standalone GitHub: [`https://github.com/nafeestariq567/BraveDebloat`](https://github.com/nafeestariq567/BraveDebloat)

---

## 2. Quick Command Reference

```powershell
# 1. Run Taskbar Sleep Fix
irm https://raw.githubusercontent.com/nafeestariq567/Windows11-Taskbar-Sleep-Fix/main/Fix_Taskbar_Sleep_Icons.ps1 | iex

# 2. Run Windows Hello PIN Fix
irm https://raw.githubusercontent.com/nafeestariq567/Windows11-PIN-Fix/main/Fix_Windows_Hello_PIN.ps1 | iex

# 3. Run Win11 Debloat Suite
irm https://raw.githubusercontent.com/nafeestariq567/Win11Debloat/main/Apply-Win11Debloat.ps1 | iex

# 4. Run Brave Browser Debloat
irm https://raw.githubusercontent.com/nafeestariq567/BraveDebloat/main/Apply-BraveDebloat.ps1 | iex
```
