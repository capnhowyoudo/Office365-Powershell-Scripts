<#
.SYNOPSIS
Disables automatic replies for a mailbox.

.DESCRIPTION
This cmdlet turns off auto-reply functionality for the specified mailbox by setting the
AutoReplyState to Disabled. Once disabled, internal and external senders will no longer
receive any automated response.

This cmdlet works in both **Exchange On-Premises (Exchange Management Shell)** and
**Exchange Online (Exchange Online PowerShell module)** with the same syntax.

.EXAMPLE
This example disables automatic replies for the "HRTeam" shared mailbox:

Set-MailboxAutoReplyConfiguration -Identity "HRTeam" -AutoReplyState Disabled

This example works in both **Exchange On-Prem** and **Exchange Online**.
#>

# Disable mailbox auto-reply configuration
Set-MailboxAutoReplyConfiguration -Identity "SharedMailboxName" -AutoReplyState Disabled
