<#
.SYNOPSIS
Sets mailbox forwarding for a mailbox and keeps a copy of the email in the source mailbox.

.DESCRIPTION
This script uses the Set-Mailbox cmdlet to forward all incoming messages from
the source mailbox to a target mailbox while retaining a copy in the original mailbox.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement (for Exchange Online)
- Exchange Management Shell (for on-premises Exchange)

Parameters:
-ForwardingAddress : The mailbox to which emails will be forwarded.
-DeliverToMailboxAndForward : When set to $true, the source mailbox retains a copy
 of all forwarded emails. If set to $false, emails are only delivered to the
 forwarding mailbox and not retained in the source mailbox.

Compatibility:
- Works in both Exchange Online and on-premises Exchange environments.

The Set-Mailbox cmdlet is available after connecting to Exchange Online
using Connect-ExchangeOnline or in the Exchange Management Shell for on-premises Exchange.
#>

# Forward emails from SourceMailbox to TargetMailbox and keep a copy in SourceMailbox

Set-Mailbox "SourceMailbox" -ForwardingAddress "TargetMailbox" -DeliverToMailboxAndForward $true
