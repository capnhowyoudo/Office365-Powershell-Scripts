<#
.SYNOPSIS
Set all user calendars to read-only access for the Default user in Exchange Online.

.DESCRIPTION
This script connects to Exchange Online, iterates through all user mailboxes, 
and sets the calendar folder permissions for the Default user to Reviewer. 
Reviewer permission allows read-only access to the calendar, ensuring users can view free/busy information 
without modifying any calendar items.

.NOTES
- Connect-ExchangeOnline must be run first to authenticate.
- Identity: The mailbox calendar in the format alias@domain.com:\Calendar
- User: Default refers to all users
- AccessRights: Reviewer grants read-only access
- Common AccessRights levels:
    • Owner – Full control including permission management
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

foreach ($usermbx in Get-Mailbox -RecipientTypeDetails UserMailbox) {
    $usercalendar = $usermbx.Alias + ":\Calendar"
    Set-MailboxFolderPermission -Identity $usercalendar -User Default -AccessRights Reviewer
}
