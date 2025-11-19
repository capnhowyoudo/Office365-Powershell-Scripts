<#
.SYNOPSIS
Shows calendar permissions for a specific user across all mailboxes.

.DESCRIPTION
This script retrieves the calendar folder permissions for a given user 
(user@onmicrosoft.com in this example) from every mailbox in the organization. 
It outputs the mailbox identity, the user, and the assigned access rights.

.NOTES
• Replace 'user@onmicrosoft.com' with the email address you want to check.
• ErrorAction SilentlyContinue is used to skip mailboxes where the user has no permissions.
• Can be extended to export results to CSV if needed.
#>

Get-Mailbox | ForEach {
    Get-MailboxFolderPermission (($_.PrimarySmtpAddress.ToString()) + ":\Calendar") -User user@onmicrosoft.com -ErrorAction SilentlyContinue
} | Select-Object Identity, User, AccessRights

.Export to CSV

$OutputFile = "C:\Temp\CalendarPermissions.csv"

Get-Mailbox | ForEach-Object {
    Get-MailboxFolderPermission (($_.PrimarySmtpAddress.ToString()) + ":\Calendar") -User user@onmicrosoft.com -ErrorAction SilentlyContinue
} | Select-Object Identity, User, AccessRights |
Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "Calendar permissions exported to $OutputFile"
