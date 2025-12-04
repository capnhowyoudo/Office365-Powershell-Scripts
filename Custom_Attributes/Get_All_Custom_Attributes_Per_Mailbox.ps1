<#
.SYNOPSIS
Displays all custom attributes for a specific mailbox.

.DESCRIPTION
This script retrieves all mailbox custom attributes (CustomAttribute1 through CustomAttribute15) 
for a specified mailbox. It helps in auditing, reporting, or verifying the values of custom attributes 
applied to the mailbox.

.NOTES
Module Required:
    - Exchange Online PowerShell (EXO V2 module)
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - Replace the mailbox identity with the target mailbox.
    - Custom attributes can be used for categorization, retention policies, or mail flow rules.
    - All custom attributes (CustomAttribute1–CustomAttribute15) will be displayed.
#>

# Get all custom attributes for a mailbox
Get-Mailbox -Identity user@example.com | Select-Object *CustomAttribute*
