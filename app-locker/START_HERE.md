# Start Here: Universal Desktop App Locker

Welcome to the **Universal Desktop App Locker** (`app-locker`). This module provides password protection for desktop application shortcuts on Windows 11.

---

## 🤖 AI Agent Quick Start Prompt

When starting a new session in this module, the user will typically say:
> *"I am working inside `C:\Win11\app-locker`. Review `README.md` and help me lock/unlock [AppName] or manage master passwords."*

---

## 🧭 Key Capabilities & Scripts

- **Lock App:** [`Lock-App.ps1`](Lock-App.ps1) (Interactive or `-ShortcutName <name>`)
- **Unlock App:** [`Unlock-App.ps1`](Unlock-App.ps1) (Interactive or `-ShortcutName <name>`)
- **Launch Gatekeeper:** [`Launch-App.ps1`](Launch-App.ps1) + [`Launch-Silent.vbs`](Launch-Silent.vbs)
- **Password Reset:** [`Reset-Password.ps1`](Reset-Password.ps1)

---

## ⚠️ Safety & Reversibility Rules

1. **Always preserve shortcut launch parameters:** Some applications (like Brave Beta) require specific flags (e.g., `--proxy-server="socks5://127.0.0.1:40000"`). The script automatically parses and persists these flags in `apps/<appkey>.json`.
2. **Always backup the original `.lnk` file:** Placed in `apps/<appkey>.original.lnk` so that unlocking is 100% loss-free.
3. **Never store plaintext passwords:** Master passwords must always be stored as a salted SHA-256 hash in `config/master.hash`.
