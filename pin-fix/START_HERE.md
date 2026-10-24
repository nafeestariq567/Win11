# Start Here: Windows 11 PIN & Hello Workspace

Welcome to the **Windows 11 PIN & Hello Workspace**. This repository contains the complete diagnostic context, root cause analysis, and automated repair scripts for the recurring Windows Hello PIN corruption issue on Windows 11.

---

## 1. Quick Start for a Fresh Chat Session

When starting a new chat in this workspace (`C:\Windows11-PIN-Fix`), simply paste:

> *"I am working inside `C:\Windows11-PIN-Fix`. Please review `README.md` and `CONTEXT_AND_TRANSCRIPT.md`. Let's check my Windows Hello PIN and TPM health status."*

---

## 2. Host Machine Profile & Architecture

- **Host Device:** Acer Predator PH317-53 Laptop
- **OS Edition:** Windows 11 Professional 64-bit (Build `26100` / `26300` series)
- **Security Hardware:** Intel TPM 2.0 (PTT, Firmware Version: `403.1.0.0`)
- **Key Subsystem:**
  - `Ngc` Credential Vault: `C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc`
  - Core Services: `CryptSvc`, `KeyIso`, `NgcCtnrSvc`, `VaultSvc`
  - Power Scheme: S3 Sleep with Hybrid Sleep disabled, Hibernate idle set to 0 (Never).

---

## 3. Related Prior Projects
- **Windows 11 Debloat Suite:** Completed and maintained at `C:\Debloat Windows 11` (GitHub: `https://github.com/nafeestariq567/Win11Debloat`).
- **Brave Browser Debloat:** Completed and maintained at `C:\BraveDebloat` (GitHub: `https://github.com/nafeestariq567/BraveDebloat`).

---

## 4. File Index

- [`README.md`](file:///C:/Windows11-PIN-Fix/README.md) - Project overview, forensic analysis, and 1-liner install instructions.
- [`CONTEXT_AND_TRANSCRIPT.md`](file:///C:/Windows11-PIN-Fix/CONTEXT_AND_TRANSCRIPT.md) - Deep technical transcript, event log signatures, and troubleshooting history.
- [`Fix_Windows_Hello_PIN.ps1`](file:///C:/Windows11-PIN-Fix/Fix_Windows_Hello_PIN.ps1) - Core PowerShell repair script.
- [`Run_Fix_PIN_Admin.cmd`](file:///C:/Windows11-PIN-Fix/Run_Fix_PIN_Admin.cmd) - Self-elevating 1-click execution wrapper.
- [`assets/pin_error_screen.jpeg`](file:///C:/Windows11-PIN-Fix/assets/pin_error_screen.jpeg) - Photo of original lock screen error.
