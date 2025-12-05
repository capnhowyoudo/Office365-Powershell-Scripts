<#
.SYNOPSIS
Invites an external user (guest) to Azure AD / Microsoft Entra ID using Microsoft Graph.

.DESCRIPTION
This script connects to Microsoft Graph with the required User.Invite.All permission and
creates a guest invitation for the specified external user. The user receives an email
invitation and is redirected to the specified URL after accepting.

REQUIRES:
- Microsoft Graph PowerShell module already installed
- Permission scope: User.Invite.All

.EXAMPLE
Example 1:
Invite John Doe (fake external user):

New-MgInvitation -InvitedUserEmailAddress "john.doe.external@examplemail.net" `
    -SendInvitationMessage $true `
    -InvitedUserDisplayName "John Doe" `
    -InviteRedirectUrl "https://portal.contosoapps.net"

Example 2:
Invite Sarah Smith with a redirect to MyApps:

New-MgInvitation -InvitedUserEmailAddress "sarah.smith.guest@fakemail.org" `
    -SendInvitationMessage $true `
    -InvitedUserDisplayName "Sarah Smith" `
    -InviteRedirectUrl "https://myapps.microsoft.com"

Example 3:
Invite Robert Turner from a partner company:

New-MgInvitation -InvitedUserEmailAddress "robert.turner@partnerco-demo.biz" `
    -SendInvitationMessage $true `
    -InvitedUserDisplayName "Robert Turner" `
    -InviteRedirectUrl "https://teams.microsoft.com"

#>

# Connect to Microsoft Graph (requires User.Invite.All)
Connect-MgGraph -Scopes "User.Invite.All"

$InvitedUserEmail = "external.user@example.com"
$InvitedUserDisplayName = "External User Name"
$RedirectURL = "https://myapps.microsoft.com" # The link the user lands on after accepting

New-MgInvitation -InvitedUserEmailAddress $InvitedUserEmail `
    -SendInvitationMessage $true `
    -InvitedUserDisplayName $InvitedUserDisplayName `
    -InviteRedirectUrl $RedirectURL
