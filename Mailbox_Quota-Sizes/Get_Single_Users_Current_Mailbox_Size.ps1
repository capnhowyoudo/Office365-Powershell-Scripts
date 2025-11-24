<#
.SYNOPSIS
Retrieves the mailbox statistics for a specified user and sorts the results by total item size, displaying the top 100 largest mailboxes.

.DESCRIPTION
This script retrieves mailbox statistics for a specified mailbox, sorts the results by total item size in descending order, and selects the top 100 mailboxes with the largest item sizes. It then re-sorts the results in ascending order and displays the display name and total item size for each mailbox.

.PARAMETER Identity
Specifies the email address of the mailbox for which the statistics are being retrieved. The parameter should be in the format of a valid email address (e.g., user@example.com).

.NOTES
Example Usage:
    Get-Mailbox -ResultSize Unlimited -Identity "user@example.com" | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName, TotalItemSize -First 100 | Sort-Object TotalItemSize
    This will retrieve and display the top 100 largest mailboxes for "user@example.com", sorted by total item size.

This script helps administrators identify large mailboxes and analyze mailbox storage usage.

#>

# Retrieve mailbox statistics for "user@example.com", sort by total item size, select top 100, then sort in ascending order

Get-Mailbox -ResultSize Unlimited -Identity "user@example.com" | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName, TotalItemSize -First 100 | Sort-Object TotalItemSize
