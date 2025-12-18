<#
.SYNOPSIS
Grants Send on Behalf permissions to a mailbox for a specified user.

.DESCRIPTION
This script uses the Set-Mailbox cmdlet to grant Send on Behalf permissions
to a mailbox. When granted, the specified user can send emails on behalf
of the mailbox, and recipients will see both the sender and the mailbox
in the From field (for example: "Admin on behalf of User").

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement

What Send on Behalf does:
Send on Behalf permission allows a user to send email on behalf of another
mailbox. Recipients will see the message as sent by the user *on behalf of*
the mailbox, unlike Send As where only the mailbox name is shown.

The Set-Mailbox cmdlet is available after connecting to Exchange Online
using Connect-ExchangeOnline.
#>

# Grant Send on Behalf permission to a mailbox
Set-Mailbox user@domain.com `
  -GrantSendOnBehalfTo admin@domain.com
