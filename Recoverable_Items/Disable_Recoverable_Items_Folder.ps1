<#
.SYNOPSIS
Disables Single Item Recovery for a mailbox.

.DESCRIPTION
This command sets the SingleItemRecoveryEnabled property on a mailbox to `$false`,
which disables the ability to recover individual deleted items from the Recoverable Items folder.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
Replace "<account>" with the mailbox you want to configure.
#>

Set-Mailbox "<account>" -SingleItemRecoveryEnabled $false
