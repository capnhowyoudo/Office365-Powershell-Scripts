<#
.SYNOPSIS
Removes mailbox forwarding from a mailbox.

.DESCRIPTION
This script uses the Set-Mailbox cmdlet to remove any forwarding that was
previously set on a mailbox. After running this, emails will only be delivered
to the original mailbox and not forwarded elsewhere.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement (for Exchange Online)
- Exchange Management Shell (for on-premises Exchange)

Parameters:
-ForwardingAddress : Setting this to $null removes any forwarding mailbox.
-DeliverToMailboxAndForward : Setting this to $false ensures no copies of
 emails are forwarded; emails remain only in the original mailbox.

Compatibility:
- Works in both Exchange Online and on-premises Exchange environments.

Additional notes:
- Use this command to completely stop forwarding and ensure all messages
  remain in the original mailbox.
#>

# Remove mailbox forwarding and ensure emails stay in the original mailbox
Set-Mailbox "SourceMailbox" -ForwardingAddress $null -DeliverToMailboxAndForward $false
