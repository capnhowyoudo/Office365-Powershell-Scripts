<#
.SYNOPSIS
Displays all mailboxes with their assigned retention policies, including archive mailboxes.
#>

Get-EXOMailbox -ResultSize Unlimited -Properties RetentionPolicy -Archive | Select-Object Name, RetentionPolicy

Export to CSV

Get-EXOMailbox -ResultSize Unlimited -Properties RetentionPolicy -Archive | Select-Object Name,RetentionPolicy | Export-Csv "C:\Temp\MailboxRetentionPolicies.csv" -NoTypeInformation






