<#
.SYNOPSIS
Updates the password for a Microsoft 365 user and forces password change at next sign-in.

.DESCRIPTION
Connects to Microsoft Graph, then updates the specified user's password using a secure string.
The user will be required to change the password on their next sign-in.

.NOTES
Requires Microsoft Graph PowerShell module (Mg) and the User.ReadWrite.All permission.
Use generic placeholders for user account and password.
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Define user and new password
$userUPN="<user account sign in name, such as user@example.com>"
$newPassword="<new password>"

# Convert password to secure string
$secPassword = ConvertTo-SecureString $newPassword -AsPlainText -Force

# Update user password and require change at next sign-in
Update-MgUser -UserId $userUPN -PasswordProfile @{ ForceChangePasswordNextSignIn = $true; Password = $newPassword }
