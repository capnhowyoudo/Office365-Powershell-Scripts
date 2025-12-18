<#
.SYNOPSIS
Verifies mailbox forwarding settings for a specific user.

.DESCRIPTION
This script retrieves the forwarding configuration of a mailbox, showing
whether emails are being forwarded and if a copy is kept in the original mailbox.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement (for Exchange Online)
- Exchange Management Shell (for on-premises Exchange)

Parameters:
-Identity : The mailbox to check forwarding settings for.

Properties to check:
- ForwardingAddress : Shows the mailbox where emails are forwarded (if any).
- DeliverToMailboxAndForward : Indicates if a copy is kept in the original mailbox.

Compatibility:
- Works in both Exchange Online and on-premises Exchange environments.
#>

# Verify forwarding settings for a specific mailbox
Get-Mailbox -Identity "user@domain.com" | Select-Object DisplayName, ForwardingAddress, DeliverToMailboxAndForward
