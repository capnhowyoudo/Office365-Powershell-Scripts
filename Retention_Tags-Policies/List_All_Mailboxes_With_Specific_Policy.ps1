<#
.SYNOPSIS
Displays and exports all mailboxes assigned to a specific retention policy in Microsoft 365.

.DESCRIPTION
This script retrieves all mailboxes in the organization and filters them based on the 
Retention Policy currently applied. It outputs a table with the mailbox name and the 
assigned retention policy, and also exports the results to a CSV file. This is useful for 
auditing or verifying which mailboxes are under a specific retention policy.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - Replace the retention policy name with your environment-specific policy.
    - Appropriate Exchange Online administrative permissions are required to view mailbox properties.
    - To get a list of all retention policies available in your environment, use:
      Get-RetentionPolicy
    - CSV export path can be updated to a preferred location.
#>

$OutputCSV = "C:\Temp\MailboxesWithRetentionPolicy.csv"

$Mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RetentionPolicy -eq "Default MRM Policy"}

# Display in table format
$Mailboxes | Format-Table Name, RetentionPolicy -AutoSize

# Export to CSV
$Mailboxes | Select-Object Name, RetentionPolicy | Export-Csv -Path $OutputCSV -NoTypeInformation -Encoding UTF8

Write-Host "Mailboxes report displayed and exported to: $OutputCSV" -ForegroundColor Green
