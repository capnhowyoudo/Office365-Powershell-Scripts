<#
.SYNOPSIS
Displays and exports all mailboxes in Microsoft 365 with their assigned retention policies.

.DESCRIPTION
This script retrieves all mailboxes in the organization, selects the DisplayName and RetentionPolicy 
for each mailbox, and sorts the results by DisplayName. The output is displayed in a table and 
exported to a CSV file for auditing or documentation purposes.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - Appropriate Exchange Online administrative permissions are required to view mailbox properties.
    - To get a list of all retention policies available in your environment, use:
      Get-RetentionPolicy
    - The CSV export path can be updated as needed.
#>

$OutputCSV = "C:\Temp\AllMailboxesWithRetentionPolicy.csv"

$Mailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName, RetentionPolicy | Sort-Object DisplayName

# Display in table format
$Mailboxes | Format-Table DisplayName, RetentionPolicy -AutoSize

# Export to CSV
$Mailboxes | Export-Csv -Path $OutputCSV -NoTypeInformation -Encoding UTF8

Write-Host "Mailbox retention policy report displayed and exported to: $OutputCSV" -ForegroundColor Green
