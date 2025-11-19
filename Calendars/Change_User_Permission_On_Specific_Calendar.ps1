<#
.SYNOPSIS
Grants a user Editor access to a mailbox calendar.

.DESCRIPTION
This cmdlet assigns the specified access rights (Editor) to a user for a given mailbox's Calendar folder. Replace mailbox and user emails with your target accounts.

.NOTES
- Use to delegate calendar management tasks.
- Verify the mailbox and user before applying permissions.
- Common access rights:
  • Owner – Read, create, modify, delete all items/folders; can manage permissions.
  • PublishingEditor – Read, create, modify, delete items and subfolders.
  • Editor – Read, create, modify, delete items.
  • PublishingAuthor – Read, create all items/subfolders; modify/delete only own items.
  • Author – Create/read items; edit/delete own items.
  • NonEditingAuthor – Read full access and create items; delete only own items.
  • Reviewer – Read only.
  • Contributor – Create items and folders.
  • AvailabilityOnly – Read free/busy information from calendar.
  • LimitedDetails – View subject and location only.
  • None – No permissions.
#>

Set-MailboxFolderPermission -Identity user@example.com:\Calendar -User delegate@example.com -AccessRights Editor
