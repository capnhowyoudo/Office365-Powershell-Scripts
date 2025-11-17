<#
.SYNOPSIS
Get all user mailboxes that currently have an active archive mailbox, with an option to export results to CSV.
#>

Get-Mailbox -Filter {ArchiveStatus -Eq "Active" -AND RecipientTypeDetails -eq "UserMailbox"} | Select-Object DisplayName,PrimarySmtpAddress,ArchiveStatus 

Export to CSV

Get-Mailbox -Filter {ArchiveStatus -Eq "Active" -AND RecipientTypeDetails -eq "UserMailbox"} | Select-Object DisplayName,PrimarySmtpAddress,ArchiveStatus | Export-Csv "C:\Temp\ActiveArchiveMailboxes.csv" -NoTypeInformation
