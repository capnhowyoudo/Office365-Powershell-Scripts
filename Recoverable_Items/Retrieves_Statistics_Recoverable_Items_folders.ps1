<#
.SYNOPSIS
Retrieves statistics for the Recoverable Items folders of a mailbox.

.DESCRIPTION
This command queries the mailbox for all folders within the Recoverable Items
scope, returning key properties such as Identity, FolderAndSubfolderSize, and FolderId.
It is useful for auditing mailbox recoverable items and tracking storage usage.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
Replace "user@domain.com" with the mailbox you want to query.
#>

Get-MailboxFolderStatistics -Identity "user@domain.com" -FolderScope RecoverableItems | Select-Object Identity, FolderAndSubfolderSize, FolderId

#Export to CSV

Get-MailboxFolderStatistics -Identity "user@domain.com" -FolderScope RecoverableItems | Select-Object Identity, FolderAndSubfolderSize, FolderId | Export-Csv "C:\Temp\MailboxRecoverableItems.csv" -NoTypeInformation

