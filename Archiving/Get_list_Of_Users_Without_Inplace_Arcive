<# 
.SYNOPSIS
Get all user mailboxes that do NOT have an archive mailbox enabled.
#>

Get-Mailbox -Filter {ArchiveStatus -Eq "None" -AND RecipientTypeDetails -eq "UserMailbox"}

Export to CSV

Get-Mailbox -Filter {ArchiveStatus -Eq "None" -AND RecipientTypeDetails -eq "UserMailbox"} | Select-Object DisplayName,PrimarySmtpAddress,ArchiveStatus | Export-Csv "C:\Temp\NoArchiveMailboxes.csv" -NoTypeInformation
