<#
.SYNOPSIS
Enables automatic replies for a mailbox.

.DESCRIPTION
This cmdlet enables automatic replies for the specified mailbox by setting the
AutoReplyState to Enabled. When enabled, internal and external senders will receive
the specified auto-reply messages.

This cmdlet works in both **Exchange On-Premises (Exchange Management Shell)** and
**Exchange Online (Exchange Online PowerShell module)** with identical syntax.
#>

# Enable mailbox auto-reply configuration
Set-MailboxAutoReplyConfiguration -Identity "MailboxName" -AutoReplyState Enabled
