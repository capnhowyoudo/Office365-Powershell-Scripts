<#
.SYNOPSIS
Enables Single Item Recovery for a mailbox.

.DESCRIPTION
This command sets the SingleItemRecoveryEnabled property on a mailbox to `$true`,
which allows recovery of individual deleted items from the Recoverable Items folder.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
Replace "<account>" with the mailbox you want to configure.
#>

Set-Mailbox "<account>" -SingleItemRecoveryEnabled $true
