<#
.SYNOPSIS
Shows the archive mailbox size (TotalItemSize) for a specific user mailbox.
#>

Get-Mailbox -Identity "user@example.com" | Get-MailboxStatistics -Archive -ErrorAction SilentlyContinue | Format-Table DisplayName,TotalItemSize
