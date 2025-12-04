<#
.SYNOPSIS
Exports all custom attributes for all mailboxes to a CSV file.

.DESCRIPTION
This script retrieves the values of all mailbox custom attributes (CustomAttribute1 through CustomAttribute15)
for all mailboxes in the organization. It is useful for auditing, reporting, or verifying custom attribute
assignments across all mailboxes. The results are displayed and exported to a CSV file.

.NOTES
Module Required:
    - Exchange Online PowerShell (EXO V2 module)
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - Custom attributes (CustomAttribute1–CustomAttribute15) can be used for categorization, retention policies, or mail flow rules.
    - Supports large numbers of mailboxes.
    - CSV export allows easy reporting and further analysis.
#>

# Connect to Exchange Online (if not already connected)
# Connect-ExchangeOnline -UserPrincipalName admin@example.com

# Retrieve all mailboxes and select custom attributes
$AllMailboxesCustomAttributes = Get-Mailbox -ResultSize Unlimited | 
    Select-Object DisplayName, UserPrincipalName, 
        CustomAttribute1, CustomAttribute2, CustomAttribute3, CustomAttribute4, CustomAttribute5,
        CustomAttribute6, CustomAttribute7, CustomAttribute8, CustomAttribute9, CustomAttribute10,
        CustomAttribute11, CustomAttribute12, CustomAttribute13, CustomAttribute14, CustomAttribute15

# Display on screen
$AllMailboxesCustomAttributes | Format-Table -AutoSize

# Export to CSV
$AllMailboxesCustomAttributes | Export-Csv "C:\Temp\AllMailboxes_CustomAttributes.csv" -NoTypeInformation -Encoding UTF8
