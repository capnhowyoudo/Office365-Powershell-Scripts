<#
.SYNOPSIS
Retrieves the display names and email addresses of all users.
#>

Get-Mailbox | Select-Object DisplayName,PrimarySmtpAddress
