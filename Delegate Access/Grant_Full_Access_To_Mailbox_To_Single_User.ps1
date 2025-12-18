<#
.SYNOPSIS
Grants FullAccess permissions to a mailbox for a specified user with AutoMapping enabled.

.DESCRIPTION
This script uses the Add-MailboxPermission cmdlet to assign FullAccess rights
to a target mailbox. AutoMapping is explicitly enabled so the mailbox is
automatically added to the user’s Outlook profile.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement

What AutoMapping does:
When AutoMapping is set to $true, Exchange automatically adds the shared or
additional mailbox to the user’s Outlook profile during autodiscover. The
mailbox appears automatically in Outlook without requiring manual addition.
This setting primarily affects Outlook for Windows and does not impact OWA.

Turning AutoMapping off:
If you do not want the mailbox to be automatically added to Outlook, set
-AutoMapping to $false when running the Add-MailboxPermission cmdlet.

The Add-MailboxPermission cmdlet is available after connecting to Exchange Online
using Connect-ExchangeOnline.
#>

# Grant FullAccess permission to a mailbox with AutoMapping enabled
Add-MailboxPermission `
  -Identity user@domain.com `
  -User admin@domain.com `
  -AccessRights FullAccess `
  -InheritanceType All `
  -AutoMapping $true
