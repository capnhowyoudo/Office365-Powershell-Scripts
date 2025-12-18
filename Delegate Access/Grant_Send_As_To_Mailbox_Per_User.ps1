<#
.SYNOPSIS
Grants Send As permissions to a mailbox for a specified user.

.DESCRIPTION
This script uses the Add-RecipientPermission cmdlet to allow a specified user
to send email as the target mailbox. When granted, messages sent by the trustee
will appear as if they were sent directly from the mailbox owner.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement

What Send As does:
Send As permission allows the trustee to send messages that appear to come
from the mailbox itself. The recipient will only see the mailbox address in
the From field, not the sender’s address.

The Add-RecipientPermission cmdlet is available after connecting to Exchange Online
using Connect-ExchangeOnline.
#>

# Grant Send As permission to a mailbox
Add-RecipientPermission `
  -Identity user@domain.com `
  -Trustee admin@domain.com `
  -AccessRights SendAs
