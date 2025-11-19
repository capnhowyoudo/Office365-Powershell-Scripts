<#
.SYNOPSIS
Shows the archive mailbox size (TotalItemSize) for all mailboxes.
#>

Get-Mailbox | Get-MailboxStatistics -Archive -ErrorAction SilentlyContinue | Format-Table DisplayName,TotalItemSize
