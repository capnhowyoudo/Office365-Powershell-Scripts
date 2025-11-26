<#
.SYNOPSIS
Retrieves all Microsoft 365 users and checks whether each user's password is set to never expire.

.DESCRIPTION
Connects to Microsoft Graph, retrieves all users including UserPrincipalName and PasswordPolicies,
and displays whether each user has the DisablePasswordExpiration policy enabled.

.NOTES
Requires Microsoft Graph PowerShell module (Mg) and appropriate permissions.
#>

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

#Get all users and check if password expiration is disabled
Get-MgUser -All -Property UserPrincipalName, PasswordPolicies | Select-Object UserPrincipalName,@{N="PasswordNeverExpires";E={$_.PasswordPolicies -match "DisablePasswordExpiration"}}

#Export to CSV
Get-MgUser -All -Property UserPrincipalName, PasswordPolicies | Select-Object UserPrincipalName,@{N="PasswordNeverExpires";E={$_.PasswordPolicies -match "DisablePasswordExpiration"}} | Export-Csv "C:\Temp\PasswordNeverExpires.csv" -NoTypeInformation

#Export to HTML
Get-MGuser -All -Property UserPrincipalName, PasswordPolicies | Select-Object UserprincipalName,@{N="PasswordNeverExpires";E={$_.PasswordPolicies -match "DisablePasswordExpiration"}} | ConvertTo-Html | Out-File "C:\Temp\ReportPasswordNeverExpires.html"
