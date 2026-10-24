# Custom Brave & Brave Beta Debloat Toolkit

> A lightweight, fast, and clutter-free toolkit to bring the "Brave Origin" experience with built-in privacy shield protections to both **Brave Stable** and **Brave Beta** on Windows 11.

---

## ⚡ Instant Install (PowerShell One-Liner)

To apply this entire debloat configuration on any fresh Windows install in seconds, open **PowerShell as Administrator** and paste:

```powershell
irm https://raw.githubusercontent.com/nafeestariq567/BraveDebloat/main/Apply-BraveDebloat.ps1 | iex
```

---

## 💾 Alternative Installation Methods

### Method 2: The One-Click Launcher
1. Download this repository (click **Code** -> **Download ZIP** and extract).
2. Double-click **`Run-Debloat.cmd`**.
3. Click **Yes** on the UAC prompt to automatically apply all policies.

### Method 3: Standalone Registry File (Zero Scripts)
1. Download or copy **`BraveDebloat.reg`**.
2. Double-click **`BraveDebloat.reg`** and click **Yes** to merge into Windows Registry.
3. Open Brave and you're good to go!

---

## 📋 Complete Configuration Profile

### ❌ Disabled (Bloat, Telemetry, and Clutter)
| Feature | Policy Name | Result |
|---|---|---|
| **Brave Rewards** | `BraveRewardsDisabled = 1` | Removes BAT icon & ad notifications |
| **Brave Wallet** | `BraveWalletDisabled = 1` | Removes Web3 wallet button & script injection |
| **Brave VPN** | `BraveVPNDisabled = 1` | Removes VPN toolbar button & upsell prompts |
| **Brave News** | `BraveNewsDisabled = 1` | Completely disables the news feed on New Tab page |
| **Brave Talk** | `BraveTalkDisabled = 1` | Removes video conferencing shortcuts & widgets |
| **IPFS Protocol** | `IPFSEnabled = 0` | Disables decentralized IPFS node/gateway handling |
| **Tor Windows** | `TorDisabled = 1` | Prevents Tor background daemon downloads |
| **Brave Playlist** | `BravePlaylistEnabled = 0` | Disables offline media playlist features |
| **Wayback Machine 404s**| `BraveWaybackMachineEnabled = 0`| Disables archive.org prompts on missing pages |
| **New Tab Cards** | `NTPCardsVisible = 0` | Hides all widget cards from the New Tab page |
| **Media Recommendations**| `MediaRecommendationsEnabled = 0`| Hides recommended media promotional cards |
| **Google Search Side Panel**| `GoogleSearchSidePanelEnabled = 0`| Disables side panel button for Google searches |
| **Promotions & Popups** | `PromotionsEnabled = 0` | Disables promotional feature spotlights |
| **Promotional Tabs** | `PromotionalTabsEnabled = 0` | Disables first-run/update marketing tabs |
| **Browser Labs** | `BrowserLabsEnabled = 0` | Hides experimental Labs entry points |
| **Shopping & Deals** | `ShoppingListEnabled = 0` | Disables automatic coupon popups & price tracking |
| **Payment Method Probing**| `PaymentMethodQueryEnabled = 0`| Blocks sites from silently checking for stored cards |
| **Password Manager** | `PasswordManagerEnabled = 0` | Disables built-in saving (external manager used) |
| **Background Mode** | `BackgroundModeEnabled = 0` | Forces Brave to exit completely on window close |
| **Brave Telemetry** | `BraveStatsPingEnabled = 0`, `BraveP3AEnabled = 0` | Stops daily ping and usage analytics |
| **Web Discovery Project**| `BraveWebDiscoveryEnabled = 0`| Stops contributing searches to Brave index |
| **Chromium Metrics** | `MetricsReportingEnabled = 0`, `UrlKeyedAnonymizedDataCollectionEnabled = 0` | Disables crash & URL metrics |

### ✅ Kept Active (Your Preferences)
| Feature | Policy Name | Result |
|---|---|---|
| **Brave Leo AI** | `BraveAIChatEnabled = 1` | Active for page summaries, Q&A, and sidebar chat |
| **Brave Email Aliases** | `EmailAliasesEnabled = 1` | Active for generating burner/masked emails on forms |
| **Brave Speedreader** | `BraveSpeedreaderEnabled = 1` | Active for distraction-free article reader view |
| **QR Code Generator** | `QRCodeGeneratorEnabled = 1` | Active in address bar for sharing URLs to mobile |

### 🛡️ Enhanced Anti-Tracking Shields (Enforced ON)
| Shield Feature | Policy Name | Result |
|---|---|---|
| **De-AMP** | `BraveDeAmpEnabled = 1` | Automatically redirects Google AMP links to real publisher pages |
| **Debouncing** | `BraveDebouncingEnabled = 1` | Skips bounce tracking redirect hops |
| **Global Privacy Control**| `BraveGlobalPrivacyControlEnabled = 1` | Transmits GPC header requesting sites not sell data |
| **Tracking Query Filtering**| `BraveTrackingQueryParametersFilteringEnabled = 1`| Automatically strips `utm_*`, `fbclid`, and tracking query tags |
| **Reduce Language** | `BraveReduceLanguageEnabled = 1` | Reduces language fingerprinting vectors |

---

## 🛠️ Repository Contents

* **[`Run-Debloat.cmd`](file:///C:/BraveDebloat/Run-Debloat.cmd)**: One-click launcher that elevates to Administrator and runs the debloat setup.
* **[`Apply-BraveDebloat.ps1`](file:///C:/BraveDebloat/Apply-BraveDebloat.ps1)**: Master PowerShell script that applies this exact configuration and checks for VPN services.
* **[`BraveDebloat.reg`](file:///C:/BraveDebloat/BraveDebloat.reg)**: Standalone Windows Registry file containing all policies.
* **[`Restore-BraveDefaults.ps1`](file:///C:/BraveDebloat/Restore-BraveDefaults.ps1)** / **[`BraveRestore.reg`](file:///C:/BraveDebloat/BraveRestore.reg)**: Instant one-click revert back to default stock Brave.
