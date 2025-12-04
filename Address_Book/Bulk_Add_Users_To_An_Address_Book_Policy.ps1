<#
.SYNOPSIS
Applies an Address Book Policy (ABP) to multiple mailboxes from a CSV file.

.DESCRIPTION
This script reads a CSV file containing mailbox identities and the desired Address Book Policy (ABP) to apply.  
It loops through each entry and updates the mailbox with the specified ABP using Set-Mailbox.  
This is useful for bulk assignment of ABPs in Microsoft 365 environments.

.NOTES
Module Required:
    - Exchange Online PowerShell (EXO V2 module)
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - CSV file must contain at least two columns: Identity, AddressBookPolicy.
    - Identity can be the mailbox email address, alias, or UPN.
    - Supports bulk updates for large numbers of mailboxes.
    - Address Book Policies control what address lists and global address lists users can see.
#>

# Example CSV structure
# Identity,AddressBookPolicy
# user1@example.com,ABP-Default
# user2@example.com,ABP-Finance

# Import CSV and apply Address Book Policy
Import-Csv "C:\Temp\addressbookpolicy.csv" | ForEach-Object {
    Set-Mailbox -Identity $_.Identity -AddressBookPolicy $_.AddressBookPolicy
}
