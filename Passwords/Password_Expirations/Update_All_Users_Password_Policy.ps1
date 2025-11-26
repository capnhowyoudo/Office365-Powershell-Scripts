<#
.SYNOPSIS
Disables or Enables password expiration for all Microsoft 365 users.

.DESCRIPTION
Retrieves all users in the tenant using Get-MgUser and updates each user to have the
DisablePasswordExpiration policy, effectively setting their passwords to never expire.

.NOTES
Requires Microsoft Graph PowerShell module (Mg) and appropriate permissions.
#>

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

#Disable password expiration for all users
Get-MgUser -All | Update-MgUser -PasswordPolicies DisablePasswordExpiration

#Enable password expiration for all users
Get-MGuser -All | Update-MgUser -PasswordPolicies None
