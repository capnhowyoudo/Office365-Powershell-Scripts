<#
.SYNOPSIS
Retrieves the display names and email addresses of all users.
#>

Get-Mailbox | Select-Object DisplayName,PrimarySmtpAddress

#export to CSV

Get-Mailbox | Select-Object DisplayName,PrimarySmtpAddress | Export-Csv -Path "C:\Temp\Mailboxes.csv" -NoTypeInformation -Encoding UTF8
