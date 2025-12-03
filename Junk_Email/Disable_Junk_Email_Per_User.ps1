<#
.SYNOPSIS
Disables Junk Email filtering for a mailbox.

.DESCRIPTION
This command configures the mailbox to disable Junk Email filtering by setting
the Enabled property to `$false`. Use this to stop the mailbox from processing
messages according to the Junk Email settings.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
Replace "user@domain.com" with the mailbox you want to configure.
#>

Set-MailboxJunkEmailConfiguration "user@domain.com" -Enabled $false
