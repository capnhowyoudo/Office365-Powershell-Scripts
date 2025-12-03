<#
.SYNOPSIS
Enables Junk Email filtering for a mailbox.

.DESCRIPTION
This command configures the mailbox to enable Junk Email filtering by setting
the Enabled property to `$true`. It is used to ensure the mailbox processes
incoming messages according to the configured Junk Email settings.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
Replace "user@domain.com" with the mailbox you want to configure.
#>

Set-MailboxJunkEmailConfiguration "user@domain.com" -Enabled $true
