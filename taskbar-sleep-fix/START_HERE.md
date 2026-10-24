# Start Here: Windows 11 Taskbar Sleep Icon Fix

Welcome to the **Windows 11 Taskbar Sleep Icon Fix** workspace. This repository contains the diagnostic context, forensic root cause breakdown, and automated repair scripts for resolving taskbar icons turning blank/invisible upon waking from sleep.

---

## 1. Host Machine Profile & Architecture

- **Host Device:** Acer Predator PH317-53 Laptop
- **OS Edition:** Windows 11 Professional 64-bit (Build `26300.9711` / 24H2 GE release)
- **Primary Display:** Internal 17.3" Panel (`AUO409D`) @ **144 Hz**, driven by **Intel(R) UHD Graphics 630**
- **Secondary Display:** External Lenovo Monitor (`LEN60A8`) @ **60 Hz**, driven by **NVIDIA GeForce RTX 2070 with Max-Q Design**
- **Taskbar Configuration:** Multi-Monitor Taskbar Mode = 2 (`MMTaskbarMode = 2` — Taskbar where window is open)

---

## 2. File Index

- [`README.md`](README.md) — Comprehensive technical documentation, forensic analysis, and 1-liner install command.
- [`Fix_Taskbar_Sleep_Icons.ps1`](Fix_Taskbar_Sleep_Icons.ps1) — Core PowerShell repair script.
- [`Refresh_Taskbar.cmd`](Refresh_Taskbar.cmd) — Instant 1-second shell reload launcher.
- [`assets/`](assets/) — Visual evidence from host displays and community reports.

---

## 3. Related Projects

- **Windows 11 Master Suite:** [`https://github.com/nafeestariq567/Win11`](https://github.com/nafeestariq567/Win11)
- **Windows Hello PIN Corruption Resolver:** [`https://github.com/nafeestariq567/Windows11-PIN-Fix`](https://github.com/nafeestariq567/Windows11-PIN-Fix)
- **Windows 11 Debloat Suite:** [`https://github.com/nafeestariq567/Win11Debloat`](https://github.com/nafeestariq567/Win11Debloat)
- **Brave Browser Debloat:** [`https://github.com/nafeestariq567/BraveDebloat`](https://github.com/nafeestariq567/BraveDebloat)
