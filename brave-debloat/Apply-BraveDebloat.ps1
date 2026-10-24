<#
.SYNOPSIS
    Comprehensive Brave & Brave Beta Debloat Script (Brave Origin + OSFV Fine-Tuned)
.DESCRIPTION
    Applies enterprise group policies tailored to user preferences:
    - DISABLING: Rewards, Wallet, VPN, News, Talk, IPFS, Tor, Telemetry, Background Mode,
                 Shopping, Password Manager, Playlist, Wayback Machine, New Tab Cards,
                 Google Search Side Panel, Promotions/Labs, and Payment Method Probing.
    - KEEPING ACTIVE: Leo AI, Email Aliases, Speedreader, QR Code Generator.
    - ENFORCING PRIVACY SHIELDS: De-AMP, Debouncing, GPC, Query Filtering, Language Reduction.
#>

[CmdletBinding()]
param()

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Brave & Brave Beta Debloat Script (Origin + OSFV Tuned) " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$policies = [ordered]@{
    # Disablement Policies (Bloat & Clutter)
    "BraveRewardsDisabled"                         = 1
    "BraveWalletDisabled"                          = 1
    "BraveVPNDisabled"                             = 1
    "BraveNewsDisabled"                            = 1
    "BraveTalkDisabled"                            = 1
    "IPFSEnabled"                                  = 0
    "TorDisabled"                                  = 1
    "BravePlaylistEnabled"                         = 0
    "BraveWaybackMachineEnabled"                   = 0
    "NTPCardsVisible"                              = 0
    "MediaRecommendationsEnabled"                  = 0
    "GoogleSearchSidePanelEnabled"                 = 0
    "PromotionsEnabled"                            = 0
    "PromotionalTabsEnabled"                       = 0
    "BrowserLabsEnabled"                           = 0
    "ShoppingListEnabled"                          = 0
    "PaymentMethodQueryEnabled"                    = 0
    "PasswordManagerEnabled"                       = 0
    "BackgroundModeEnabled"                        = 0

    # Telemetry Disablement
    "BraveStatsPingEnabled"                        = 0
    "BraveP3AEnabled"                              = 0
    "BraveWebDiscoveryEnabled"                     = 0
    "MetricsReportingEnabled"                      = 0
    "UrlKeyedAnonymizedDataCollectionEnabled"      = 0

    # Kept Active (User Choice)
    "BraveAIChatEnabled"                           = 1
    "EmailAliasesEnabled"                          = 1
    "BraveSpeedreaderEnabled"                      = 1
    "QRCodeGeneratorEnabled"                       = 1

    # Privacy Protection Shields (Enforced ON)
    "BraveDeAmpEnabled"                            = 1
    "BraveDebouncingEnabled"                       = 1
    "BraveGlobalPrivacyControlEnabled"             = 1
    "BraveTrackingQueryParametersFilteringEnabled" = 1
    "BraveReduceLanguageEnabled"                   = 1
}

$targets = @(
    "HKCU:\SOFTWARE\Policies\BraveSoftware\Brave",
    "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
)

foreach ($target in $targets) {
    Write-Host "[*] Applying fine-tuned policies to $target..." -ForegroundColor Green
    try {
        if (-not (Test-Path $target)) {
            New-Item -Path $target -Force | Out-Null
        }

        foreach ($name in $policies.Keys) {
            $val = $policies[$name]
            Set-ItemProperty -Path $target -Name $name -Value $val -Type DWord -Force

            if ($name -in @("BraveAIChatEnabled", "EmailAliasesEnabled", "BraveSpeedreaderEnabled", "QRCodeGeneratorEnabled")) {
                Write-Host "    [ACTIVE]   $name = $val (User preference kept)" -ForegroundColor Yellow
            }
            elseif ($name -in @("BraveDeAmpEnabled", "BraveDebouncingEnabled", "BraveGlobalPrivacyControlEnabled", "BraveTrackingQueryParametersFilteringEnabled", "BraveReduceLanguageEnabled")) {
                Write-Host "    [SHIELD]   $name = $val (Anti-tracking active)" -ForegroundColor Cyan
            }
            else {
                Write-Host "    [DISABLED] $name = $val" -ForegroundColor Gray
            }
        }
    }
    catch {
        Write-Warning "Could not write to $target (requires Administrator privileges for HKLM)."
    }
}

# Check and disable Brave VPN background services if present
Write-Host ""
Write-Host "[*] Checking for Brave VPN background services..." -ForegroundColor Green
$vpnServices = @("BraveVpnService", "BraveVpnWireguardService")
foreach ($svc in $vpnServices) {
    $serviceObj = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($serviceObj) {
        Write-Host "    Found service '$svc' (Status: $($serviceObj.Status)). Disabling..." -ForegroundColor Yellow
        try {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "    [OK] Service '$svc' stopped and set to Disabled." -ForegroundColor Green
        }
        catch {
            Write-Warning "    Could not modify service '$svc'. Run PowerShell as Administrator."
        }
    } else {
        Write-Host "    [INFO] Service '$svc' is not present." -ForegroundColor Gray
    }
}

# Check if Brave processes are active
$braveProcs = Get-Process -Name "brave*" -ErrorAction SilentlyContinue
if ($braveProcs) {
    Write-Host ""
    Write-Host "[!] Note: Brave or Brave Beta is currently running." -ForegroundColor Yellow
    Write-Host "    Restart your browser to activate the new configuration." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "[OK] Browser changes will take effect next time Brave starts." -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Setup complete! Verify in your browser at: brave://policy" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
