# Start Here: Resuming in a Fresh Chat

Follow these simple steps to continue Windows 11 debloating in a fresh chat session:

---

### Step 1: Open a New Chat

Open your terminal or UI in the target folder:
```powershell
cd "C:\Debloat Windows 11"
```

---

### Step 2: Paste the Kick-Off Prompt

Send this prompt in the new chat:

```text
Let's continue Windows 11 debloating. We are working inside C:\Debloat Windows 11.
Please read README.md, PREFERENCES_CHECKLIST.md, and WIN11_DEBLOAT_ROADMAP.md.
Let's first review my preferences and perform the Step 1 safety baseline (Restore Point + Registry Backup).
```

---

### Step 3: What the Assistant Will Do

1. **Verify the environment**: Confirms Windows 11 Pro edition and active configuration.
2. **Review your preferences**: Asks which apps (e.g. Xbox, OneDrive, Copilot, Phone Link) you want kept vs. removed from [`PREFERENCES_CHECKLIST.md`](file:///C:/Debloat%20Windows%2011/PREFERENCES_CHECKLIST.md).
3. **Establish safety**: Creates a system restore point and registry export in `Backups/`.
4. **Implement modular scripts**: Creates transparent, fully-reversible `.ps1` and `.reg` scripts for telemetry, apps, services, and shell tweaks.
5. **Zero Silent or Unapproved Decisions (Strict Mandate)**: Never make assumptions or dumb hidden decisions. If any package, background service, or setting is discovered that is not explicitly approved, discuss it with the user first with a 1-line description and get explicit permission.
