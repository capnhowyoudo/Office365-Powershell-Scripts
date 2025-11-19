<#
.SYNOPSIS
View Clutter status for all user mailboxes.

.DESCRIPTION
This script retrieves the Clutter status for every user mailbox in Exchange Online.
It lists each user and whether Clutter is enabled or disabled, and optionally exports the results to a CSV file.

.NOTES
Requires an active Exchange Online PowerShell session.
Exports results to C:\Temp\ClutterStatus.csv
#>

# --- Variables ---
$CsvPath = "C:\Temp\ClutterStatus.csv"
$WhatIf = $true  # Set to $false to allow export

# Create folder if it doesn't exist
if (-not (Test-Path "C:\Temp")) { New-Item -Path "C:\Temp" -ItemType Directory | Out-Null }

# Get all user mailboxes
$allUsers = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

# Collect Clutter info
$clutterStatus = foreach ($user in $allUsers) {
    $status = Get-Clutter -Identity $user.UserPrincipalName
    [PSCustomObject]@{
        UserPrincipalName = $user.UserPrincipalName
        ClutterEnabled    = $status.Enable
    }
}

# Display results
$clutterStatus | Format-Table -AutoSize

# Export to CSV if WhatIf is false
if (-not $WhatIf) {
    $clutterStatus | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "Results exported to $CsvPath" -ForegroundColor Green
} else {
    Write-Host "WhatIf is enabled. No CSV export performed." -ForegroundColor Yellow
}
