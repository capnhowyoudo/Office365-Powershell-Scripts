<#
.SYNOPSIS
Updates the CustomAttribute1 property for multiple mailboxes from a CSV file.

.DESCRIPTION
This script reads a CSV file containing mailbox identities and values for CustomAttribute1.  
It loops through each entry and applies the value to the corresponding mailbox using Set-Mailbox.  
This is useful for bulk updates of mailbox custom attributes for categorization, reporting, or mail flow rules.

.NOTES
Module Required:
    - Exchange Online PowerShell (EXO V2 module)
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - CSV file must contain at least two columns: Identity, CustomAttribute1.
    - Identity can be the mailbox email address, alias, or UPN.
    - Supports bulk updates for large numbers of mailboxes.
    - Available mailbox custom attributes:
        - CustomAttribute1
        - CustomAttribute2
        - CustomAttribute3
        - CustomAttribute4
        - CustomAttribute5
        - CustomAttribute6
        - CustomAttribute7
        - CustomAttribute8
        - CustomAttribute9
        - CustomAttribute10
        - CustomAttribute11
        - CustomAttribute12
        - CustomAttribute13
        - CustomAttribute14
        - CustomAttribute15
#>

# Example CSV structure
# Identity,CustomAttribute1
# user1@example.com,Marketing
# user2@example.com,Finance

# Import CSV and update mailboxes
Import-Csv "C:\Temp\customattribute.csv" | ForEach-Object {
    Set-Mailbox -Identity $_.Identity -CustomAttribute1 $_.CustomAttribute1
}
