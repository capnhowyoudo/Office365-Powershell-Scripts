<#
.SYNOPSIS
Configures the deleted item retention period for a mailbox.

.DESCRIPTION
This command sets the RetainDeletedItemsFor property on a mailbox, which controls
how long deleted items are retained before permanent removal. In this example, it
is set to 14 days.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
Replace "<account>" with the mailbox you want to configure.
The retention period format is `dd:hh:mm:ss` (days:hours:minutes:seconds).
#>

Set-Mailbox "<account>" -RetainDeletedItemsFor 14.00:00:00
