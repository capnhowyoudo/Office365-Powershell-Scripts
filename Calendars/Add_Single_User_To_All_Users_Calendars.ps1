<#
.SYNOPSIS
Adds or updates calendar permissions for a specific user across all mailboxes.

.DESCRIPTION
This script loops through all mailboxes in the organization and ensures that the specified user
has the specified access rights to the calendar of every mailbox except their own. If the user already has 
permissions on a mailbox, those permissions are first removed and then re-added to ensure consistency.

.NOTES
• Replace $userToAdd with the desired email address to assign calendar permissions.
• Set $accessRights to change the permission level (e.g., Editor, Reviewer, Author, etc.).
• The script skips adding permissions to the mailbox of the user being granted access.
• ErrorAction SilentlyContinue is used to avoid breaking if permissions do not exist.
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

# -------- Configurable Variables --------
$userToAdd = "user@example.com"  # Replace with the target user
$accessRights = "Editor"         # Change access rights before running (e.g., Reviewer, Author)

$users = Get-Mailbox | Select -ExpandProperty PrimarySmtpAddress

Foreach ($u in $users)
{
    $ExistingPermission = Get-MailboxFolderPermission -Identity $u":\calendar" -User $userToAdd -EA SilentlyContinue
    if ($ExistingPermission) {Remove-MailboxFolderPermission -Identity $u":\calendar" -User $userToAdd -Confirm:$False}
    if ($u -ne $userToAdd) {Add-MailboxFolderPermission $u":\Calendar" -User $userToAdd -AccessRights $accessRights}
}
