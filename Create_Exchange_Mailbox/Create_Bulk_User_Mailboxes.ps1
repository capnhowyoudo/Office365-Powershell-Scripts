<#
.SYNOPSIS
Creates new user mailboxes in Exchange Online from a CSV file or individually.

.DESCRIPTION
This script allows creating new user mailboxes either for a single user or multiple users using a CSV file. 
The script will prompt for a secure password that will be applied to all new mailboxes.

.NOTES
- Requires an active Exchange Online PowerShell session.
- Email addresses are placeholders; replace with your organization’s domain as needed.
- Password is entered securely via Read-Host.
- - Example CSV format:
FirstName,LastName,Alias,DisplayName,Email,ResetPasswordOnNextLogon
John,Smith,john.smith,John Smith,john.smith@genericdomain.com,FALSE
Jane,Doe,jane.doe,Jane Doe,jane.doe@genericdomain.com,TRUE
#>

# Variable for WhatIf
$WhatIf = $true  # Set to $false to actually create mailboxes

# Prompt for password for all new mailboxes
$Password = Read-Host "Enter password for new mailbox(es)" -AsSecureString

# Path to CSV file
$CsvPath = Read-Host "Enter path to CSV file for bulk mailbox creation (leave blank for single user)"

if ($CsvPath -and (Test-Path $CsvPath)) {
    # Bulk creation from CSV
    $Users = Import-Csv $CsvPath
    foreach ($User in $Users) {
        $ResetPwd = if ($User.ResetPasswordOnNextLogon) { [bool]::Parse($User.ResetPasswordOnNextLogon) } else { $false }
        Write-Host "Creating mailbox for $($User.DisplayName) <$($User.Email)>" -ForegroundColor Green
        New-Mailbox -Alias $User.Alias `
                    -Name "$($User.FirstName) $($User.LastName)" `
                    -FirstName $User.FirstName `
                    -LastName $User.LastName `
                    -DisplayName $User.DisplayName `
                    -MicrosoftOnlineServicesID $User.Email `
                    -Password $Password `
                    -ResetPasswordOnNextLogon $ResetPwd `
                    -WhatIf:$WhatIf
    }
}
else {
    # Single mailbox creation
    $FirstName = Read-Host "Enter First Name"
    $LastName  = Read-Host "Enter Last Name"
    $Alias     = Read-Host "Enter Alias"
    $Email     = Read-Host "Enter Email"
    $DisplayName = "$FirstName $LastName"
    $ResetPwd  = Read-Host "Reset password on next logon? (TRUE/FALSE)" 

    New-Mailbox -Alias $Alias `
                -Name $DisplayName `
                -FirstName $FirstName `
                -LastName $LastName `
                -DisplayName $DisplayName `
                -MicrosoftOnlineServicesID $Email `
                -Password $Password `
                -ResetPasswordOnNextLogon ([bool]::Parse($ResetPwd)) `
                -WhatIf:$WhatIf
}
