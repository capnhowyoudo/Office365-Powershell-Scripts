<#
.SYNOPSIS
Removes FullAccess permissions from a mailbox for a specified user.

.DESCRIPTION
This script uses the Remove-MailboxPermission cmdlet to remove previously
assigned FullAccess rights from a mailbox. After removal, the user will no
longer be able to open or access the mailbox.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement

Additional information:
If AutoMapping was previously enabled, Outlook may continue to display the
mailbox until the client cache is refreshed or Outlook is restarted.

The Remove-MailboxPermission cmdlet is available after connecting to Exchange Online
using Connect-ExchangeOnline.
#>

# Remove FullAccess permission from a mailbox
Remove-MailboxPermission `
  -Identity user@domain.com `
  -User admin@domain.com `
  -AccessRights FullAccess
