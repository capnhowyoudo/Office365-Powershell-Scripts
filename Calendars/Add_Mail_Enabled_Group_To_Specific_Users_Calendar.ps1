<#
.SYNOPSIS
Adds a mail-enabled security group to a user's calendar with specific permissions.

.DESCRIPTION
This script allows you to grant calendar access to a mail-enabled security group (MESG) 
for a specific mailbox. The group will have configurable access rights and delegate permissions.
Before running this script, ensure the mail-enabled security group exists and contains all intended users.

.NOTES
• Replace the variables below with actual values.
• Make sure you are connected to Exchange Online via PowerShell:
  Connect-ExchangeOnline 
  
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
    
• To create a mail-enabled security group in Exchange Online:
  1. Connect to Exchange Online PowerShell:
     Connect-ExchangeOnline -UserPrincipalName admin@domain.com
  2. Run:
     New-DistributionGroup -Name "GroupName" -Alias "GroupAlias" -Type Security -PrimarySmtpAddress "MESG@domain.com" -Members "user1@domain.com","user2@domain.com"
  3. Verify group membership:
     Get-DistributionGroupMember -Identity "MESG@domain.com"
     
#>

# ---------------- Variables ----------------
$CalendarOwner   = "User@domain.com"          # Calendar owner's email
$GroupToAdd      = "MESG@domain.com"         # Mail-enabled security group
$PermissionLevel = "Editor"                  # AccessRights (Editor, Reviewer, Contributor, etc.)

# ---------------- Command ----------------
Add-MailboxFolderPermission -Identity "$CalendarOwner:\Calendar" -User $GroupToAdd -AccessRights $PermissionLevel -SharingPermissionFlags Delegate
