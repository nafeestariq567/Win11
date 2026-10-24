# Module Quick Start: Windows Hello PIN Corruption Resolver (`pin-fix/`)

This module contains the diagnostic context, forensic root cause analysis, and automated repair scripts for resolving the recurring Windows Hello PIN corruption issue (`0xD000A002`, Event ID 7002).

> [!TIP]
> Global host architecture and verified system specs are maintained in the root file: [`../SYSTEM_SPECS.md`](../SYSTEM_SPECS.md).
> AI Agent operating protocols are in: [`../START_HERE.md`](../START_HERE.md).

---

## 1. Quick Launch (One-Liner)

```powershell
irm https://raw.githubusercontent.com/nafeestariq567/Win11/main/pin-fix/Fix_Windows_Hello_PIN.ps1 | iex
```

---

## 2. File Index

- [`README.md`](README.md) — Problem statement, forensic root cause breakdown, and 1-liner install instructions.
- [`CONTEXT_AND_TRANSCRIPT.md`](CONTEXT_AND_TRANSCRIPT.md) — Deep technical transcript, event log signatures, and troubleshooting history.
- [`Fix_Windows_Hello_PIN.ps1`](Fix_Windows_Hello_PIN.ps1) — Core PowerShell repair script.
- [`Run_Fix_PIN_Admin.cmd`](Run_Fix_PIN_Admin.cmd) — Self-elevating 1-click execution wrapper.
- [`assets/pin_error_screen.jpeg`](assets/pin_error_screen.jpeg) — Photo of original lock screen error.
