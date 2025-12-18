<#
.SYNOPSIS
Removes SendAs permissions from a mailbox for a specified user.

.DESCRIPTION
This script removes a user’s SendAs permission on a mailbox.
After removal, the user can no longer send email as the mailbox.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement

Example:
If admin@domain.com previously had SendAs permission for user@domain.com,
this will remove it.

The Remove-RecipientPermission cmdlet is available after connecting to Exchange Online
using Connect-ExchangeOnline.
#>

# Remove SendAs permission from a mailbox
Remove-RecipientPermission `
  -Identity user@domain.com `
  -Trustee admin@domain.com `
  -AccessRights SendAs
