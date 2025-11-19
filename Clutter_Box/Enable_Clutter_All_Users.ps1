<#
.SYNOPSIS
Enables Clutter for all user mailboxes in Exchange Online.

.DESCRIPTION
This script connects to Exchange Online and Enables the Clutter feature 
for every user mailbox. A WhatIf variable allows safe preview mode before 
making any changes. All output is exported to C:\Temp\DisableClutterResults.csv.

If C:\Temp does not exist, it will be created automatically.

.NOTES
• Requires Exchange Online PowerShell (EXO V2).
• Uses generic mailbox examples.
• Set $WhatIfPreference = $false to apply real changes.
#>

# ==========================
# SETTINGS
# ==========================

# Toggle WhatIf mode:
# $true  = NO CHANGES (safe mode)
# $false = Apply actual changes
$WhatIfPreference = $true

# Export location
$ExportPath = "C:\Temp"
$CsvFile = "$ExportPath\DisableClutterResults.csv"

# ==========================
# PREP WORK
# ==========================

# Create folder if missing
if (!(Test-Path $ExportPath)) {
    New-Item -Path $ExportPath -ItemType Directory | Out-Null
}

# Array to collect results
$Results = @()

# Connect to Exchange Online
Connect-ExchangeOnline

Write-Host "Processing all user mailboxes..." -ForegroundColor Yellow

# Get all mailboxes
$Mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

# ==========================
# MAIN LOOP
# ==========================
foreach ($Mailbox in $Mailboxes) {

    Write-Host "Processing: $($Mailbox.PrimarySmtpAddress)" -ForegroundColor Cyan

    # Disable Clutter with variable WhatIf mode
    Set-Clutter -Identity $Mailbox.PrimarySmtpAddress `
                -Enable $true `
                -WhatIf:$WhatIfPreference `
                -ErrorAction SilentlyContinue

    # Log results
    $Results += [PSCustomObject]@{
        User        = $Mailbox.PrimarySmtpAddress
        Action      = "Disable Clutter"
        WhatIfMode  = $WhatIfPreference
        Timestamp   = (Get-Date)
    }
}

# ==========================
# EXPORT RESULTS
# ==========================
$Results | Export-Csv -Path $CsvFile -NoTypeInformation -Force

Write-Host "=======================================================" -ForegroundColor Green
Write-Host "     Clutter Disable Script Completed" -ForegroundColor Green

if ($WhatIfPreference -eq $true) {
    Write-Host "   MODE: WHATIF (No changes were applied)" -ForegroundColor Yellow
} else {
    Write-Host "   MODE: LIVE (Changes were applied)" -ForegroundColor Green
}

Write-Host " Export saved to: $CsvFile" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
