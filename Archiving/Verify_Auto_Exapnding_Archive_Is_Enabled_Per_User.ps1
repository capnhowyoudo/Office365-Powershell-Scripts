<#
.SYNOPSIS
Shows whether Auto-Expanding Archive is enabled for a specific mailbox.
#>

Get-Mailbox <UserMailbox> | FL AutoExpandingArchiveEnabled
