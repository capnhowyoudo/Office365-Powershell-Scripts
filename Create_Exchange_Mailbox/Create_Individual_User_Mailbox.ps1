<#
.SYNOPSIS
Creates a new user mailbox in Exchange Online.

.DESCRIPTION
This cmdlet creates a new user mailbox for John Smith with a specified alias, name, display name, and Microsoft Online Services ID (email).
It prompts for a secure password at runtime and optionally sets whether the user must reset the password at next logon.

.NOTES
- Requires an active Exchange Online PowerShell session.
- Email address is a generic placeholder. Replace with your organization’s domain as needed.
- Password is entered securely via Read-Host.
#>

$Password = Read-Host "Enter password for new mailbox" -AsSecureString

New-Mailbox -Alias "john.smith" `
            -Name "John Smith" `
            -FirstName "John" `
            -LastName "Smith" `
            -DisplayName "John Smith" `
            -MicrosoftOnlineServicesID "john.smith@genericdomain.com" `
            -Password $Password `
            -ResetPasswordOnNextLogon $false
