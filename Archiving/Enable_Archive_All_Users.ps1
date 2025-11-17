<#
.SYNOPSIS
Enables archive mailboxes for all user mailboxes that currently do not have an archive.
#>

Get-Mailbox -Filter {ArchiveStatus -Eq "None" -AND RecipientTypeDetails -eq "UserMailbox"} | Enable-Mailbox -Archive

Export to CSV

Get-Mailbox -Filter {ArchiveStatus -Eq "None" -AND RecipientTypeDetails -eq "UserMailbox"} | Enable-Mailbox -Archive | Select-Object DisplayName,PrimarySmtpAddress,ArchiveStatus | Export-Csv -Path "C:\Temp\EnabledArchives.csv" -NoTypeInformation






