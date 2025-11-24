<#
.SYNOPSIS
Retrieves mailbox folder statistics for a specified user and exports the relevant data to a CSV file.

.DESCRIPTION
This script retrieves the folder statistics for a specified mailbox, including the identity of the folder, the number of items in each folder, and the folder size. The data is then exported to a CSV file for further analysis.

.PARAMETER Identity
Specifies the email address of the mailbox for which folder statistics are being retrieved. The parameter should be in the format of a valid email address (e.g., user@example.com).

.NOTES
Example Usage:
    Get-MailboxFolderStatistics -Identity "user@example.com" | Select-Object Identity, ItemsInFolder, FolderSize | Export-Csv C:\Path\To\Export\Stats.csv -NoTypeInformation
    This will export the folder statistics of the mailbox "user@example.com" to `C:\Path\To\Export\Stats.csv`.

This script is useful for administrators who need to review mailbox folder sizes and item counts.

#>

# Retrieve folder statistics for the mailbox "user@example.com" and export the data to a CSV file

Get-MailboxFolderStatistics -Identity "user@example.com" | Select-Object Identity, ItemsInFolder, FolderSize 

Export to CSV

Get-MailboxFolderStatistics -Identity "user@example.com" | Select-Object Identity, ItemsInFolder, FolderSize | Export-Csv C:\Path\To\Export\Stats.csv -NoTypeInformation
