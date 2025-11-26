<#
.SYNOPSIS
Automates Office 365 password expiry notifications by sending reminder emails to users.

.DESCRIPTION
This script connects to Microsoft Graph using an App ID and certificate, iterates through all enabled users,
checks their password expiration dates, and sends reminder emails to users whose passwords will expire within a specified threshold.
The script also logs each email sent for auditing purposes.

Steps to use this script:

Step 1: Create an App ID and Grant Permissions
- Create an App ID in Azure AD to connect with Microsoft Graph:
  https://www.sharepointdiary.com/2023/04/how-to-connect-to-microsoft-graph-api-from-powershell.html
- Make sure you grant the App ID the permissions: “User.Read.All” and “Mail.Send”.

Step 2: Update the Parameters in this PowerShell Script
- Update the script parameters section with your TenantID, ClientID, CertificateThumbprint, SenderID, LogFilePath, and thresholds.
- This script can save significant productivity time, as users will be notified before password expiry, avoiding lockouts and disruptions.

Step 3: Schedule the PowerShell Script
- Create an automated system to run this script daily using:
  - Task Scheduler: https://www.sharepointdiary.com/2013/03/create-scheduled-task-for-powershell-script.html
  - Or Azure Automation Runbook: https://www.sharepointdiary.com/2020/11/sharepoint-online-schedule-powershell-script-using-azure-automation.html

By following these steps, you will help users stay informed about their password expiration dates and maintain secure access to Office 365 accounts.
#>

# ======================
# Script Parameters
# ======================
$TenantID = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
$ClientID = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx" # App ID
$CertThumbPrint = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$LogFilePath = "C:\Scripts\PasswordExpiry.Log"
$SenderID = "Helpdesk@yourdomain.com"
$NotificationThreshold = 15
$PasswordExpiryThreshold = 90

# ======================
# Function: Write-Log
# ======================
Function Write-Log {
    [CmdletBinding()]
    Param ([Parameter(Mandatory=$true)][string]$Message)  
    Process{
        # Append log with timestamp
        "$([datetime]::Now) : $Message" | Out-File -FilePath $LogFilePath -Append
        # Write log message to console
        Write-Host "$([datetime]::Now) : $Message"
    }
}

# ======================
# Connect to Microsoft Graph
# ======================
Connect-MgGraph -ClientID $ClientID -TenantId $TenantID -CertificateThumbprint $CertThumbPrint

# Ensure the log folder exists
$FolderPath = Split-Path $LogFilePath
If (!(Test-Path -Path $FolderPath)) {  
    New-Item -ItemType Directory -Path $FolderPath | Out-Null
}

# ======================
# Retrieve all users
# ======================
$AllUsers = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, Mail, UserType, AccountEnabled, PasswordPolicies, lastPasswordChangeDateTime

# ======================
# Process each user
# ======================
ForEach ($User in $AllUsers) {

    # Skip disabled accounts, guests, or users with password never expires
    If (!$User.AccountEnabled -or $User.PasswordPolicies -contains "DisablePasswordExpiration" -or $User.UserType -eq "Guest") {
        continue
    }

    # Calculate password expiry date
    $PasswordExpiryDate = $User.lastPasswordChangeDateTime.AddDays($PasswordExpiryThreshold)
    $RemainingDays = ($PasswordExpiryDate - (Get-Date)).Days

    # Check if notification is required
    If ($RemainingDays -le $NotificationThreshold -and $RemainingDays -ge 0) {

        # Email body
        $EmailBody = "
            Hello $($User.DisplayName),
            <br/><br/>
            Your Office 365 password will expire in $RemainingDays days. Please change your password before it expires to avoid any disruption.
            <br/><br/>
            To change your password, follow these steps:<br/>
            <ol>
            <li>Sign in to Office 365 (https://www.office.com)</li>
            <li>Click on your profile picture in the top right corner.</li>
            <li>Select 'View account'.</li>
            <li>Click 'Password'.</li>
            <li>Follow the instructions to change your password.</li>
            </ol>
            <br/>
            Thank you,<br/>
            IT Support Team
        "

        # Email parameters
        $MailParams = @{
            Message = @{
                Subject = "Your Office 365 password will expire soon"
                Importance = "High"
                Body = @{
                    ContentType = "html"
                    Content = $EmailBody
                }
                ToRecipients = @(
                    @{
                        EmailAddress = @{
                            Address = $User.Mail
                        }
                    }
                )
            }
        }

        # Send email
        Send-MgUserMail -UserId $SenderID -BodyParameter $MailParams

        # Log email sent
        Write-Log "Password Expiration Notification sent to user $($User.Mail) - Password Expires on $PasswordExpiryDate"
    }
}
