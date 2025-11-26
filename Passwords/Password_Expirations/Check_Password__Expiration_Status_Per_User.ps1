<#
.SYNOPSIS
Retrieves a Microsoft 365 user and checks if their password is set to never expire.

.DESCRIPTION
Gets the specified user by UserId or UPN, selects the UserPrincipalName property, 
and evaluates the PasswordPolicies property to indicate if the password never expires.

.NOTES
Requires Microsoft Graph PowerShell module (Mg) and appropriate permissions.
#>

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

Get-MgUser -UserId <user id or UPN> -Property UserPrincipalName, PasswordPolicies | Select-Object UserPrincipalName,@{N="PasswordNeverExpires";E={$_.PasswordPolicies -match "DisablePasswordExpiration"}}
