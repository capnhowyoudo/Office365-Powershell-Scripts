<#
.SYNOPSIS
Retrieve the last password change date for a specific Microsoft 365 user.

.DESCRIPTION
This script connects to Microsoft Graph, retrieves a specific user's properties including 
their UserPrincipalName, PasswordPolicies, and lastPasswordChangeDateTime, 
and outputs the information in a readable format.

.PARAMETER UserId
The UserPrincipalName or ObjectId of the user whose password information you want to retrieve.

.EXAMPLE
# Retrieve last password change date for a specific user
.\Get_Per_User_Last_Password_Change.ps1 -UserId "salaudeen@Crescent.com"

.NOTES
Written by: ALI TAJRAN
Website:    www.alitajran.com
LinkedIn:   linkedin.com/in/alitajran
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Specify the user principal name
$UserId = "salaudeen@Crescent.com"

# Retrieve user properties
$User = Get-MgUser -UserId $UserId -Property UserPrincipalName, PasswordPolicies, lastPasswordChangeDateTime

# Display relevant information
$User | Select-Object UserPrincipalName, PasswordPolicies, lastPasswordChangeDateTime
