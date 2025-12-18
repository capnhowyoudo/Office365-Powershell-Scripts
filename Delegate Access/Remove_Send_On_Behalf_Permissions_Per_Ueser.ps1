<#
.SYNOPSIS
Removes Send on Behalf permissions from a mailbox for a specified user.

.DESCRIPTION
This script removes a user from the GrantSendOnBehalfTo list on a mailbox.
After removal, the user will no longer be able to send emails on behalf
of the mailbox.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement

Example:
If admin@domain.com previously had Send on Behalf permissions for user@domain.com,
this will remove it.

The Set-Mailbox cmdlet is available after connecting to Exchange Online
using Connect-ExchangeOnline.
#>

# Remove a single user from Send on Behalf permissions
Set-Mailbox -Identity user@domain.com -GrantSendOnBehalfTo @{Remove="admin@domain.com"}

# OR, to remove all users from Send on Behalf permissions
# Set-Mailbox -Identity user@domain.com -GrantSendOnBehalfTo $null
