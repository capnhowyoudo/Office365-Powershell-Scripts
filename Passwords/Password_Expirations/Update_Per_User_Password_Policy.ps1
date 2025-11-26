<#
.SYNOPSIS
Sets a Microsoft 365 user’s password policy to never expire.

.DESCRIPTION
Uses Update-MgUser to apply the DisablePasswordExpiration policy to the specified user.

.NOTES
Requires Microsoft Graph PowerShell module (Mg) and appropriate permissions.
#>

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

#Update user password policy
Update-MgUser -UserId <user ID> -PasswordPolicies DisablePasswordExpiration
