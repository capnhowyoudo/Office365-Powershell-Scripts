<#
.SYNOPSIS
Displays the last logon time for all users.
#>

Get-Mailbox | Get-MailboxStatistics | Where-Object {$_.LastLogonTime} | Select-Object DisplayName,Name,LastLogonTime 

#Export to CSV

Get-Mailbox | Get-MailboxStatistics | Where-Object {$_.LastLogonTime} | Select-Object DisplayName,Name,LastLogonTime | Export-Csv -Path "C:\Temp\MailboxLastLogon.csv" -NoTypeInformation -Encoding UTF8
