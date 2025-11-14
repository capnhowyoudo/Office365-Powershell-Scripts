<#
.SYNOPSIS
Identifies whether an email address belongs to a user, group, distribution list, mailbox, or public folder.
#>

Get-EXORecipient -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "user@example.com"} | fl Name, RecipientType, EmailAddresses
