<#
.SYNOPSIS
Disables Junk Email filtering for all mailboxes where it is currently enabled.

.DESCRIPTION
This command retrieves all mailboxes in the organization, checks their Junk Email
configuration, filters for those with Enabled set to `$true`, and disables Junk
Email filtering by setting Enabled to `$false`.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
All mailbox references are generic.
#>

Get-Mailbox -ResultSize Unlimited | Get-MailboxJunkEmailConfiguration | Where-Object { $_.Enabled -eq $true } | Set-MailboxJunkEmailConfiguration -Enabled $false
