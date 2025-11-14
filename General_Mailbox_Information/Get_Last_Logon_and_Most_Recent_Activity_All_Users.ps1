<#
.Synopsis 
Retrieve mailbox statistics for all mailboxes, including Display Name, Last Logon Time, and Last User Action Time

.Notes 
LastLogonTime: Indicates the last time a user logged into the mailbox.
LastUserActionTime: Indicates the last time a user performed an action within the mailbox (e.g., sending, receiving, deleting an email).
#>

Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Select-Object DisplayName, LastLogonTime, LastUserActionTime

#Export to CSV

Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Select-Object DisplayName, LastLogonTime, LastUserActionTime | Export-Csv -Path "MailboxStats.csv" -NoTypeInformation
