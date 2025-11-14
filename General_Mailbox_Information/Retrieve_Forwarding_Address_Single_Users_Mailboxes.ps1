<#
.SYNOPSIS
Retrieve the forwarding addresses for a single users mailboxe.
#>

Get-Mailbox -Identity user@yourdomain.com |select UserPrincipalName,ForwardingSmtpAddress,DeliverToMailboxAndForward
