<#
.SYNOPSIS
Retrieves mailbox folder statistics for a specified user and displays the folder path, number of items in the folder and subfolders, and the size of the folder and subfolders.

.DESCRIPTION
This script retrieves the folder statistics for a specified mailbox, displaying the folder path, the number of items in the folder and its subfolders, and the total size of the folder and subfolders.

.PARAMETER Identity
Specifies the email address of the mailbox for which folder statistics are being retrieved. The parameter should be in the format of a valid email address (e.g., user@example.com).

.NOTES
Example Usage:
    Get-MailboxFolderStatistics -Identity "user@example.com" | Format-Table FolderPath, ItemsInFolderAndSubfolders, FolderAndSubfolderSize
    This will display folder statistics for the mailbox "user@example.com", including the folder path, item count, and folder size.

This script is useful for administrators who need to review mailbox folder sizes and item counts for mailbox management or reporting.

#>

# Retrieve folder statistics for the mailbox "user@example.com" and display the relevant details

Get-MailboxFolderStatistics -Identity "user@example.com" | Format-Table FolderPath, ItemsInFolderAndSubfolders, FolderAndSubfolderSize

Export to CSV

Get-MailboxFolderStatistics -Identity "user@example.com" | Select-Object FolderPath, ItemsInFolderAndSubfolders, FolderAndSubfolderSize | Export-Csv -Path C:\Path\To\Export\MailboxStats.csv -NoTypeInformation
