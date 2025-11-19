<#
.SYNOPSIS
Displays the calendar folder permissions for a specified mailbox.

.DESCRIPTION
This command retrieves the list of users who have access to the specified mailbox's Calendar folder 
and shows the type of permission assigned to each user.

.NOTES
- Identity format: <Mailbox>:\<Folder>
- Useful to audit mailbox calendar sharing and delegate permissions.
- Example: Get-MailboxFolderPermission -Identity user@example.com:\Calendar
#>

Get-MailboxFolderPermission -Identity user@example.com:\Calendar

Export to CSV

Get-MailboxFolderPermission -Identity user@example.com:\Calendar | Export-Csv -Path C:\Temp\CalendarPermissions.csv -NoTypeInformation
