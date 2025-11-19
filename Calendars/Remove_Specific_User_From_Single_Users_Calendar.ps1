<#
.SYNOPSIS
Removes a specific user's permissions from a mailbox calendar.

.DESCRIPTION
This cmdlet deletes a user's access to a specified mailbox Calendar folder. Replace the mailbox and user email addresses with your target values.

.NOTES
- Use this to revoke calendar access for a delegate.
- Always verify the mailbox and user before running.
- Example: remove a user's permission from a mailbox calendar.
#>

Remove-MailboxFolderPermission -Identity user@example.com:\Calendar -User delegate@example.com
