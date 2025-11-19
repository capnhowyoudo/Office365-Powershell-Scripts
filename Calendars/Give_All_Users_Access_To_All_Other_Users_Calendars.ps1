<#
.SYNOPSIS
Set calendar permissions for all user mailboxes in Exchange Online.

.DESCRIPTION
This script connects to Exchange Online and grants each user access to all other users' calendars.
It prompts for the desired access right (Reviewer, Editor, etc.) and applies it to all user mailboxes.
Errors for users already added are ignored. Finally, the script displays all updated calendar permissions.

.NOTES
- Date: 2025-11-19
- The script requires Exchange Online PowerShell Module (Connect-ExchangeOnline).
- ExecutionPolicy should allow running scripts.
- All mailboxes are treated as generic; no personal emails are used.
- This script can be modified to target specific users or groups if needed.

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

.VARIABLES
$useAccess   - List of all user mailboxes (Identity)
$accRight    - Desired calendar access right (input from user)
$user        - Individual user mailbox from $useAccess
$mbx         - Mailbox to display updated permissions

.CHANGELOG
V1.00, 11/19/2025 - Initial version
#>

# Clear screen
cls

# Connect to Exchange Online
Connect-ExchangeOnline

Write-Output "======================================================="
Write-Host "============= Setting Calendar Permissions =============" -ForegroundColor Yellow
Write-Output "======================================================="

# Get all user mailboxes
$useAccess = Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Select-Object Identity

cls
Write-Host "AccessRights: None, Owner, PublishingEditor, Editor, PublishingAuthor, Author, NonEditingAuthor, Reviewer, Contributor" -ForegroundColor Yellow
Write-Host "This script will attempt to modify and add a user permission. Errors for already-added users can be ignored." -ForegroundColor DarkCyan
Write-Host "---------------------" -ForegroundColor Gray

# Prompt for desired access right
$accRight = Read-Host "Please enter the desired access right for all users. Ex: Reviewer"

# Loop through all users to set permissions
ForEach ($user in $useAccess) {
    Get-Mailbox -ResultSize Unlimited | ForEach-Object {
        if ($_.Identity -ne $user.Identity) {
            Add-MailboxFolderPermission "$($_.SamAccountName):\Calendar" -User $user.Identity -AccessRights $accRight -ErrorAction SilentlyContinue
            Set-MailboxFolderPermission "$($_.SamAccountName):\Calendar" -User $user.Identity -AccessRights $accRight -ErrorAction SilentlyContinue
        }
    }
}

cls
Write-Output "======================================================="
Write-Host "============ CALENDAR INFORMATION UPDATED =============" -ForegroundColor Green
Write-Output "======================================================="

# Display updated calendar permissions
ForEach ($mbx in Get-Mailbox -ResultSize Unlimited) {
    Get-MailboxFolderPermission ($mbx.Name + ":\Calendar") | Select-Object Identity,User,AccessRights | Format-Table -Wrap -AutoSize
}
