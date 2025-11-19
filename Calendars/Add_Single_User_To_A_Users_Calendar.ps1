<#
.SYNOPSIS
Grants a user Editor permissions on another user's mailbox calendar.

.DESCRIPTION
This cmdlet assigns a specified access right (Editor) to a user for the calendar folder of another mailbox. 
Editor access allows the user to read, create, modify, and delete calendar items in the target mailbox's calendar.

.PARAMETER Identity
The target mailbox and folder to which permissions will be applied. Format: <Mailbox>:\<Folder>

.PARAMETER User
The user account that will receive the permissions.

.PARAMETER AccessRights
The level of access being granted (e.g., Editor, Reviewer, Owner).

.NOTES
- Replace the email addresses with your generic or target mailbox/user.
- Ensure the executing account has the required permissions to assign mailbox folder permissions.
- Calendar is the most common folder to assign permissions, but you can adjust for other folders like Inbox.
#>

# Example command
Add-MailboxFolderPermission -Identity user@example.com:\Calendar -User delegate@example.com -AccessRights Editor
