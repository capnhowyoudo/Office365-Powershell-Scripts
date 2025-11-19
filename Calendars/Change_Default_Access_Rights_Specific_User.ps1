<#
.SYNOPSIS
Sets calendar permissions for the default account for a specific user

.DESCRIPTION
This command sets the folder permissions on a user's calendar. 
It is commonly used to grant or modify access for the Default user (all users) or a specific mailbox user.
You can specify permission levels such as Owner, Editor, Reviewer, etc.

.NOTES
- Identity: The mailbox and folder (format: user@domain.com:\FolderName)
- User: The user or group to grant permissions to (e.g., Default, a specific mailbox)
- AccessRights: Defines the permission level. Common values include:
    • Owner – Full control, including manage permissions
    • PublishingEditor – Read, create, modify, delete items/subfolders
    • Editor – Read, create, modify, delete items
    • PublishingAuthor – Read, create all items/subfolders, modify/delete own items
    • Author – Create/read items, modify/delete own items
    • NonEditingAuthor – Read all, create items, delete own items only
    • Reviewer – Read only
    • Contributor – Create items and folders only
    • AvailabilityOnly – Free/busy information
    • LimitedDetails – View subject/location only
    • None – No access
#>

Set-MailboxFolderPermission -Identity genericuser@domain.com:\Calendar -User Default -AccessRights AvailabilityOnly
