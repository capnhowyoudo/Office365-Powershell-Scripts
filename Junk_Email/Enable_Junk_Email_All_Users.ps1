<#
.SYNOPSIS
Enables Junk Email filtering for all mailboxes where it is currently disabled.

.DESCRIPTION
This command retrieves all mailboxes in the organization, checks their Junk Email
configuration, filters for those with Enabled set to `$false`, and enables Junk
Email filtering by setting Enabled to `$true`.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
All mailbox references are generic.
#>

Get-Mailbox -ResultSize Unlimited | Get-MailboxJunkEmailConfiguration | Where-Object { $_.Enabled -eq $false } | Set-MailboxJunkEmailConfiguration -Enabled $true
