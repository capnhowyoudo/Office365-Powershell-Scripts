<#
.SYNOPSIS
Removes mailbox permissions (Full Access, Send As, Send on Behalf) from a user.

.DESCRIPTION
These cmdlets remove permissions from a mailbox, preventing the specified user from
accessing or sending emails from the mailbox. Full Access removal stops the user from
opening/managing the mailbox. Send As removal prevents sending as the mailbox. Send on
Behalf removal prevents sending on behalf of the mailbox.

.NOTES
- Required Module: Exchange Online PowerShell V2 module (ExchangeOnlineManagement)
- Replace "mailbox@company.com" with the mailbox you want to remove access from.
- Replace "user@company.com" with the user whose access should be removed.

Permissions Overview:

Full Access:
    - Removes a user’s ability to open and manage the mailbox.
    - Does not affect sending emails unless combined with other permissions.

Send As:
    - Removes a user’s ability to send emails that appear to originate directly from the mailbox.

Send on Behalf:
    - Removes a user’s ability to send emails on behalf of the mailbox.
#>

# Remove Full Access permission
Remove-MailboxPermission -Identity mailbox@company.com -User user@company.com -AccessRights FullAccess

# Remove Send As permission
Remove-RecipientPermission -Identity mailbox@company.com -Trustee user@company.com -AccessRights SendAs

# Remove Send on Behalf permission
Set-Mailbox -Identity mailbox@company.com -GrantSendOnBehalfTo $null

