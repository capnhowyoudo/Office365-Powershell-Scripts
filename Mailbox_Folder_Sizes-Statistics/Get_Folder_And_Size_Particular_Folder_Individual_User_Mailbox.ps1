<#
.SYNOPSIS
Retrieves statistics for a specified folder (e.g., "Deleted Items") from a user's mailbox.

.DESCRIPTION
This cmdlet retrieves folder statistics for a specified folder (in this case, "Deleted Items") within a user's mailbox. It includes the folder name, folder path, the number of items in the folder, and the folder size. This is useful for administrators who need to monitor the size and item count of specific folders.

.PARAMETER Identity
Specifies the email address of the mailbox from which the folder statistics are being retrieved. The parameter should be in the format of a valid email address (e.g., user@example.com).

.NOTES
Example Usage:
    Get-MailboxFolderStatistics -Identity "user@example.com" | Where-Object {$_.FolderPath -eq "/Deleted Items"} | Select Name, FolderPath, ItemsInFolder, FolderSize
    This will retrieve and display the folder statistics for the "Deleted Items" folder in the mailbox "user@example.com".

This cmdlet helps administrators manage mailbox sizes and ensure that folders like "Deleted Items" are appropriately monitored.

#>

# Retrieve folder statistics for the "Deleted Items" folder from the mailbox "user@example.com" and display relevant details

Get-MailboxFolderStatistics -Identity "user@example.com" | Where-Object {$_.FolderPath -eq "/Deleted Items"} | Select Name, FolderPath, ItemsInFolder, FolderSize
