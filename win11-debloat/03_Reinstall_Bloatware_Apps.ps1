<#
.SYNOPSIS
    Rollback for Stage 2: Reinstalls removed Windows 11 apps via Winget / Microsoft Store.
.DESCRIPTION
    Reinstalls the 13 removed apps from official Microsoft Store sources using winget.
    You can run it with no parameters to reinstall all, or specify individual app IDs.
#>

[CmdletBinding()]
param(
    [string[]]$AppNames = @("All")
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Rollback Stage 2: Reinstalling Apps via Microsoft Store " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$appCatalog = @(
    @{ Name = "Xbox PC App"; Id = "9MV0B5HZVK9Z"; Package = "Microsoft.GamingApp" },
    @{ Name = "Microsoft 365 (Office)"; Id = "9WZDNCRD29V9"; Package = "Microsoft.MicrosoftOfficeHub" },
    @{ Name = "MSN News"; Id = "9WZDNCRFHVFW"; Package = "Microsoft.BingNews" },
    @{ Name = "MSN Weather"; Id = "9WZDNCRFJ3Q2"; Package = "Microsoft.BingWeather" },
    @{ Name = "Microsoft Solitaire Collection"; Id = "9WZDNCRFJ362"; Package = "Microsoft.MicrosoftSolitaireCollection" },
    @{ Name = "Microsoft To Do"; Id = "9NBLGGH5R558"; Package = "Microsoft.Todos" },
    @{ Name = "Feedback Hub"; Id = "9NBLGGH4R32N"; Package = "Microsoft.WindowsFeedbackHub" },
    @{ Name = "Get Help"; Id = "9PKDZBMV1H3T"; Package = "Microsoft.GetHelp" },
    @{ Name = "Quick Assist"; Id = "9P7BP5VNWKX5"; Package = "MicrosoftCorporationII.QuickAssist" },
    @{ Name = "Power Automate"; Id = "9NFTCH6J7FHV"; Package = "Microsoft.PowerAutomateDesktop" },
    @{ Name = "Microsoft People"; Id = "9NBLGGH10PG8"; Package = "Microsoft.People" },
    @{ Name = "Sticky Notes"; Id = "9NBLGGH4QGHW"; Package = "Microsoft.MicrosoftStickyNotes" },
    @{ Name = "Windows Media Player"; Id = "9WZDNCRFJ3PT"; Package = "Microsoft.ZuneMusic" }
)

foreach ($item in $appCatalog) {
    if ($AppNames -contains "All" -or $AppNames -contains $item.Package -or $AppNames -contains $item.Name) {
        Write-Host "[*] Installing $($item.Name) ($($item.Id))..." -ForegroundColor Yellow
        winget install --id $item.Id --source msstore --accept-package-agreements --accept-source-agreements --silent
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [+] Successfully installed $($item.Name)" -ForegroundColor Green
        } else {
            Write-Host "  [i] Winget exit code: $LASTEXITCODE. You can also install it manually from the Store: ms-windows-store://pdp/?ProductId=$($item.Id)" -ForegroundColor Gray
        }
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  Reinstallation routine finished.                        " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
