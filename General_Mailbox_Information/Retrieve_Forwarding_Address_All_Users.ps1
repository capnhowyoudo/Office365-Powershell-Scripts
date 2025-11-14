<#
.SYNOPSIS
Retrieve the forwarding addresses for all user mailboxes.
#>

Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox | Select UserPrincipalName,ForwardingSmtpAddress,DeliverToMailboxAndForward

#Export to CSV

Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox | Select-Object UserPrincipalName,ForwardingSmtpAddress,DeliverToMailboxAndForward | Export-Csv -Path "ForwardingReport.csv" -NoTypeInformation
