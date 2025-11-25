<#
.SYNOPSIS
Disables password expiration for a Microsoft 365 user.

.DESCRIPTION
Connects to Microsoft Graph, retrieves a user by UPN, checks if password expiration is enabled,
and disables it if necessary.

.NOTES
Requires Microsoft Graph PowerShell module (Mg) and User.ReadWrite.All permission.
#>

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"
 
#Get the User by user id - UPN
$User = Get-MgUser -UserId "user@example.com"
 
If($User.PasswordPolicies -ne "DisablePasswordExpiration")
{
    #Set pasword to never expire
    Update-MgUser -UserId $User.Id -PasswordPolicies DisablePasswordExpiration
    Write-host "Password set to Never Expire!" -f Green
}
Else
{
    Write-host "Password Expiration is already disabled!" -f Yellow
}
