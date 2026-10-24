# Host System Specifications & Hardware Profile

> [!IMPORTANT]
> **Single Source of Truth for AI Agents:** This document contains the verified hardware and operating system profile for this machine, taken directly from Windows Settings (`System > About`) and confirmed via low-level telemetry. **Do not modify or assume different specifications.**

---

## 1. Device Specifications

| Attribute | Specification |
|---|---|
| **Device Name** | `DESKTOP-7LV0LO3` |
| **OEM Manufacturer & Model** | Acer Predator PH317-53 |
| **Processor** | Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz (Base: 2.59 GHz, 6 Cores, 12 Logical Processors) |
| **Installed RAM** | **32.0 GB** (31.8 GB usable) @ **2667 MHz** |
| **Primary GPU (Dedicated)** | **NVIDIA GeForce RTX 2070 with Max-Q Design (8 GB GDDR6 VRAM)** |
| **Secondary GPU (Integrated)**| **Intel(R) UHD Graphics 630 (128 MB VRAM)** |
| **Storage** | 1.38 TB NVMe SSD (WDC PC SN720 / ~939 GB used) |
| **Device ID** | `EC866E8C-9794-464F-97DA-C799A054B5C9` |
| **Product ID** | `00330-51989-98145-AAOEM` |
| **System Type** | 64-bit operating system, x64-based processor |
| **Pen & Touch** | No pen or touch input is available for this display |
| **Security Hardware** | Intel Platform Trust Technology (TPM 2.0 / PTT, Firmware Version: `403.1.0.0`) |

---

## 2. Windows Specifications

| Attribute | Specification |
|---|---|
| **Edition** | **Windows 11 Pro** |
| **Version** | **26H2** |
| **Installation Date** | 5/29/2026 |
| **OS Build** | **26300.9711** (`ge_release`) |
| **Experience Pack** | Windows Feature Experience Pack `1000.26100.372.0` |
| **Primary User Account** | Muhammad Nafees Tariq (`nafeestariq2019@outlook.com` / Local User: `Nafees`) |

---

## 3. Display & Monitor Topology

- **Display 1 (Internal Laptop Panel):**
  - Identifier: `AUO409D` (17.3" IPS)
  - Driven by: **Intel(R) UHD Graphics 630** (eDP)
  - Resolution: `1920 x 1080`
  - Refresh Rate: **144 Hz**
  - Position: Primary `{X=0, Y=0}`
- **Display 2 (External Monitor):**
  - Identifier: `LEN60A8` (Lenovo Monitor)
  - Driven by: **NVIDIA GeForce RTX 2070 with Max-Q Design** (HDMI / DisplayPort)
  - Resolution: `1920 x 1080`
  - Refresh Rate: **60 Hz**
  - Position: Secondary `{X=-1920, Y=-58}`
- **Taskbar Multi-Monitor Setting:** `MMTaskbarMode = 2` (*"Show taskbar apps on: Taskbar where window is open"*).

---

## 4. Power & Sleep Configuration

- **Power Scheme:** `SCHEME_BALANCED` (381b4222-f694-41f0-9685-ff5bb260df2e)
- **Sleep State:** S3 Standby supported.
- **Hybrid Sleep:** Disabled (`0` on AC and DC).
- **Hibernate Idle Timeout (`HIBERNATEIDLE`):** Set to `0` (Never). *Essential: Prevents the NVMe 3-hour resume crash (`0xC0000225`) that corrupts TPM/PIN.*
- **Fast Startup (`HiberbootEnabled`):** Disabled (`0`).
- **PCIe Link State Power Management (ASPM):**
  - **AC Power:** `0` (Off). *Essential: Eliminates GPU TDR 141 timeouts when waking display 2 on wall power.*
  - **Battery (DC):** `2` (Maximum power savings). *Preserves 100% of battery runtime on mobile power.*
