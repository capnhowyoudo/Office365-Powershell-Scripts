<#
.SYNOPSIS
Displays and exports all Retention Policies and their linked Retention Policy Tags in Microsoft 365.

.DESCRIPTION
This script retrieves all Retention Policies configured in your Exchange Online environment and 
lists each policy with its associated Retention Policy Tags. The output is displayed in a table 
and also exported to a CSV file for auditing and documentation purposes.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - Displays all default and custom retention policies.
    - Useful for auditing policies and verifying tag assignments before applying to mailboxes.
    - Requires Exchange Online administrative permissions.
    - The CSV file will include columns: RetentionPolicyName, LinkedTags.
#>

$OutputCSV = "C:\Temp\RetentionPoliciesReport.csv"

$Policies = Get-RetentionPolicy | ForEach-Object {
    [PSCustomObject]@{
        RetentionPolicyName = $_.Name
        LinkedTags         = ($_.RetentionPolicyTagLinks -join ', ')
    }
}

# Display in table format
$Policies | Format-Table RetentionPolicyName, LinkedTags -AutoSize

# Export to CSV
$Policies | Export-Csv -Path $OutputCSV -NoTypeInformation -Encoding UTF8

Write-Host "Retention Policies report displayed and exported to: $OutputCSV" -ForegroundColor Green
