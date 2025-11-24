<#
.SYNOPSIS
Retrieves and displays mailbox statistics for a specified mailbox, including the total item size.

.DESCRIPTION
This cmdlet retrieves mailbox statistics for a specified mailbox, including the display name and total item size of the mailbox. The total item size provides an indication of how much space the mailbox is using.

.PARAMETER Identity
Specifies the email address or identity of the mailbox for which the statistics are being retrieved. The parameter should be in a valid email address format (e.g., user@example.com).

.NOTES
Example Usage:
    Get-MailboxStatistics -Identity "user@example.com" | Select-Object DisplayName, TotalItemSize
    This will retrieve and display the mailbox statistics for the mailbox "user@example.com", including the display name and total item size.

This cmdlet helps administrators to check the total size of a mailbox to monitor storage usage.

#>

# Retrieve and display mailbox statistics for the mailbox "user@example.com"

Get-MailboxStatistics -Identity "user@example.com" | Select-Object DisplayName, TotalItemSize
