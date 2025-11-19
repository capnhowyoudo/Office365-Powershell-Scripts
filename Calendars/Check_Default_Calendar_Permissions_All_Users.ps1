<#
.SYNOPSIS
Lists the calendar permissions assigned to the Default user for all mailboxes.

.DESCRIPTION
This cmdlet retrieves the calendar folder permissions for every mailbox and filters to show only the Default user access. This is useful to audit or review default access rights across all users.

.NOTES
- Identity: The mailbox and folder (Calendar) being checked.
- User: The account for which permissions are listed (Default indicates all users in the organization with no explicit delegation).
- AccessRights: The level of permissions assigned (Owner, Editor, Reviewer, etc.).
- Replace mailbox emails with your actual users if filtering for specific accounts.
#>

Get-Mailbox | ForEach-Object { Get-MailboxFolderPermission -Identity "$($_.PrimarySmtpAddress):\Calendar" } | Where-Object { $_.User -like "Default" } | Select-Object Identity, User, AccessRights

Export CSV

Get-Mailbox | ForEach-Object { Get-MailboxFolderPermission -Identity "$($_.PrimarySmtpAddress):\Calendar" } | Where-Object { $_.User -like "Default" } | Select-Object Identity, User, AccessRights | Export-Csv -Path "C:\Temp\CalendarPermissions.csv" -NoTypeInformation

