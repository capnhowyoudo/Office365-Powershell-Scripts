<#
.SYNOPSIS
Retrieves the display names and email addresses of all users.
#>

Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress, RecipientTypeDetails

#export to CSV

Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress, RecipientTypeDetails | Export-Csv -Path "C:\Temp\Mailboxes.csv" -NoTypeInformation -Encoding UTF8
