# Context & Technical Transcript: Windows Hello PIN Corruption

This document provides complete technical documentation of the recurring Windows Hello PIN corruption issue, forensic log signatures, root cause discovery, and verification history.

---

## 1. Problem Statement & User Symptoms

- **User Report:**
  > *"Every few days, my PIN gets messed up. It starts appearing like this: 'Something happened and your PIN isn't available. Click to set up your PIN again.' Even when I change the pin, or remove it and add it again, it does not work. Even if I restart my laptop, it doesn't work. Right now, it is messed up again."*
- **Visual Evidence:** Lock screen error prompt displaying *"Something happened and your PIN isn't available. Click to set up your PIN again"* with PIN/password sign-in options. Captured in [`assets/pin_error_screen.jpeg`](file:///C:/Windows11-PIN-Fix/assets/pin_error_screen.jpeg).

---

## 2. Event Log Signatures & Investigation

### A. The Lock Screen Failure Signature
At `10/21/2026 9:17:33 PM`, upon system boot:
```text
Log Name:      Microsoft-Windows-HelloForBusiness/Operational
Source:        Microsoft-Windows-HelloForBusiness
Event ID:      7002
Level:         Error
Description:   Failed to load an existing Windows Hello container.
               ID: {adf8549c-f058-42f4-b6ee-108f81b610d0}
               Error: 0xD000A002

Event ID:      5701
Description:   Windows Hello read following protector properties from disk:
               HResult = 0x0, PIN protector = false, Bio protector = false
```

### B. Historical Failure Pattern
Querying all previous occurrences of Event 7002 revealed that this corruption had occurred in multiple cycles:
- **Cycle 1 (August 28, 2026):** Container `{2bbffc7a-ec4d-4289-a506-dbedc33cbf96}` failed with `0xD000A002`.
- **Cycle 2 (September 2–6, 2026):** Container `{497f4673-9f10-4b96-8785-1378a0551ed6}` failed with `0xD000A002`.
- **Cycle 3 (October 17–21, 2026):** Container `{adf8549c-f058-42f4-b6ee-108f81b610d0}` failed with `0xD000A002`.

### C. The Root Cause Discovery (The 3-Hour Hibernate Resume Crash)
Cross-referencing the System log against every single Event 7002 occurrence identified the trigger:
```text
Event ID 16 (Kernel-Boot):  Windows failed to resume from hibernate with error status 0xC0000225 / 0xC000A002.
Event ID 41 (Kernel-Power): The system has rebooted without cleanly shutting down first.
Event ID 6008 (EventLog):   The previous system shutdown at 10/17/2026 was unexpected.
```

Checking the active power scheme (`powercfg /q SCHEME_CURRENT SUB_SLEEP`):
```text
Power Setting GUID: 9d7815a6-7ee4-497e-8888-515a05f02364 (Hibernate after)
Current AC Power Setting Index: 0x00002a30 (10,800 seconds = 3 hours)
Current DC Power Setting Index: 0x00002a30 (10,800 seconds = 3 hours)
```

**The Chain of Events:**
1. The user closes the laptop lid or puts it to sleep.
2. The laptop enters standard S3 sleep.
3. After exactly 3 hours (10,800 seconds), Windows attempts an automated background transition from Sleep to Hibernate (`hiberfil.sys`).
4. When waking from hibernate, the Acer Predator PH317-53 NVMe controller fails to restore memory context (`Error status 0xC0000225`), causing a kernel crash reboot (`Kernel-Power 41`).
5. The dirty crash corrupts the TPM 2.0 unwrap authorization context and the active `Ngc` container files on disk.
6. Upon reboot, Windows Hello fails to load `{adf8549c...}` with `0xD000A002`, displaying the lock screen error.
7. Settings cannot overwrite the container because it requires decrypting the old corrupted key first.

---

## 3. Resolution Implementation

### Step 1: Automated Resolver (`Fix_Windows_Hello_PIN.ps1`)
1. Stops `NgcCtnrSvc` (Passport Container) and `VaultSvc` (Credential Manager).
2. Takes ownership of `C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc` via `takeown` and `icacls`.
3. Purges all damaged subfolders and orphaned keys.
4. Restarts authentication services.
5. Neutralizes the 3-hour sleep-to-hibernate trigger:
   - `powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0`
   - `powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0`
   - `powercfg /SETACTIVE SCHEME_CURRENT`
6. Recreates clean hibernation memory mapping (`powercfg -h off` / `powercfg -h on`).
7. Launches `ms-settings:signinoptions`.

---

## 4. Live Verification Results (October 22, 2026)

At `6:42 AM`, the fix was executed and the user set a fresh PIN:
```text
TimeCreated           Id   Message
-----------           --   -------
10/22/2026 6:42:11 AM 5225 Creating a software Windows Hello key with result 0x0 (Success)
10/22/2026 6:42:11 AM 5702 Windows Hello wrote protector properties: PIN protector = true
10/22/2026 6:42:17 AM 5001 A user signed into the device successfully using PIN!
```
- **Error 7002:** 0 occurrences.
- **Power setting:** `HIBERNATEIDLE = 0x0` (Never).
- **Services:** `CryptSvc`, `KeyIso`, `NgcCtnrSvc`, `VaultSvc` all healthy and Running.
