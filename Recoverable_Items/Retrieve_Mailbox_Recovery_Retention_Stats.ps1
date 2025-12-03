<#
.SYNOPSIS
Retrieves mailbox retention and single-item recovery settings.

.DESCRIPTION
This command queries a mailbox and returns key properties related to
retention and recovery, specifically SingleItemRecoveryEnabled and RetainDeletedItemsFor.
It is useful for auditing mailbox recoverable item settings.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
Replace "user@domain.com" with the mailbox you want to query.
#>

Get-Mailbox "user@domain.com" | Format-List SingleItemRecoveryEnabled, RetainDeletedItemsFor
