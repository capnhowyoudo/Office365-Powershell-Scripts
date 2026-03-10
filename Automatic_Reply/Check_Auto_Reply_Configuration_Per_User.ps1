<#
.SYNOPSIS
Retrieves the automatic reply (Out of Office) configuration for a specific mailbox.

.DESCRIPTION
This command queries Exchange to display the current AutoReply (Out of Office)
settings for the specified mailbox. It shows whether automatic replies are enabled,
the internal and external messages configured, and any scheduled start or end times.

.NOTES
Generic example for reviewing mailbox automatic reply configuration.
#>

# Retrieve the automatic reply configuration for the specified mailbox
Get-MailboxAutoReplyConfiguration -Identity "user@domain.com"
