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
This example invites external.user@example.com as a guest user:

New-MgInvitation -InvitedUserEmailAddress "external.user@example.com" `
    -SendInvitationMessage $true `
    -InvitedUserDisplayName "External User Name" `
    -InviteRedirectUrl "https://myapps.microsoft.com"

This will create the guest account and send the invitation email.
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
