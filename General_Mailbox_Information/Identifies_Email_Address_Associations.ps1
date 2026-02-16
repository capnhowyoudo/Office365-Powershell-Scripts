<#
.SYNOPSIS
Identifies whether an email address belongs to a user, group, distribution list, mailbox, or public folder.
#>

#cmdlet for Exchange online

Get-EXORecipient -ResultSize unlimited | Where-Object {$_.EmailAddresses -match "user@example.com"} | fl Name, RecipientType, EmailAddresses

#cmdlet for On prem Exchange

Get-Recipient -ResultSize Unlimited | Where-Object {$_.EmailAddresses -match "user@example.com"} | Format-List Name, RecipientType, EmailAddresses
