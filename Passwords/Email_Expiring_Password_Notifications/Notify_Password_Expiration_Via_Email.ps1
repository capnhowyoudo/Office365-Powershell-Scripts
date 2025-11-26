<#
.SYNOPSIS
Send email notifications to Microsoft 365 users whose passwords are about to expire.

.DESCRIPTION
This script connects to Microsoft Graph, checks all enabled users for upcoming password expirations,
and sends email reminders to users whose passwords will expire within a specified notification threshold.
Output: Emails are sent directly to the users' Office 365 mailboxes.

.PARAMETER NotificationThreshold
Number of days before password expiration to send notification. Default is 7.

.PARAMETER PasswordExpiryThreshold
Total password validity period in days. Default is 90 days.

.EXAMPLES
# Send password expiry notifications 7 days before password expires
.\Notify_PasswordExpiry.ps1

# Change notification threshold to 5 days
$NotificationThreshold = 5

# Change password expiry threshold to 120 days
$PasswordExpiryThreshold = 120
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Mail.Send"

# Set the notification threshold - days before password expires
$NotificationThreshold = 7

# Set the password expiry threshold (total validity period in days)
$PasswordExpiryThreshold = 90

# Get all users with required properties
Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, Mail, UserType, AccountEnabled, PasswordPolicies, lastPasswordChangeDateTime | ForEach-Object {

    $User = $_

    # Skip disabled accounts, guests, or users with Password never expire flag
    If (!$User.AccountEnabled -or $User.PasswordPolicies -contains "xDisablePasswordExpiration" -or $User.UserType -eq "Guest") {
        return
    }

    # Calculate user's password expiry date
    $PasswordExpiryDate = $User.lastPasswordChangeDateTime.AddDays($PasswordExpiryThreshold)

    # Calculate remaining days until password expires
    $RemainingDays = ($PasswordExpiryDate - (Get-Date)).Days

    # Check if remaining days are within the notification threshold
    If ($RemainingDays -le $NotificationThreshold) {

        # Construct email body
        $EmailBody = "
            Hello $($User.DisplayName),
            <br/><br/>
            Your Office 365 password will expire in $RemainingDays days. Please change your password before it expires to avoid any disruption in accessing your account.
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

        # Build email parameters
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

        # Send the email using Microsoft Graph
        Send-MgUserMail -UserId $User.Mail -BodyParameter $MailParams
    }
}
