<#
.SYNOPSIS
Retrieves mailbox folder statistics from the archive for a specified user and displays relevant details.

.DESCRIPTION
This cmdlet retrieves folder statistics from the archive mailbox of a specified user. It includes information about the folder identity, the number of items in each folder, and the total size of each folder. This is useful for administrators needing to review folder statistics for archived mailboxes.

.PARAMETER Identity
Specifies the email address of the mailbox whose archive folder statistics are being retrieved. The parameter should be in the format of a valid email address (e.g., user@example.com).

.NOTES
Example Usage:
    Get-MailboxFolderStatistics -Archive -Identity "user@example.com" | Select-Object Identity, ItemsInFolder, FolderSize
    This will retrieve the folder statistics for the archive mailbox of "user@example.com" and display the identity, item count, and folder size.

This cmdlet helps administrators monitor and review archive folder sizes and item counts.

#>

# Retrieve folder statistics from the archive for the mailbox "user@example.com" and display relevant details

Get-MailboxFolderStatistics -Archive -Identity "user@example.com" | Select-Object Identity, ItemsInFolder, FolderSize
