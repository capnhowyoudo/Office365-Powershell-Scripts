<#
    .SYNOPSIS
    Set-DefCalPermissions.ps1

    .DESCRIPTION
    Set default calendar permissions for all user mailboxes including exception for users.

    The script works for:
    -Exchange On-Premises (Run Exchange Management Shell)
    -Exchange Online (Connect to Exchange Online PowerShell)

    .LINK
    alitajran.com/set-default-calendar-permissions-for-all-users-powershell

    .NOTES
    Written by: ALI TAJRAN
    Website:    alitajran.com
    LinkedIn:   linkedin.com/in/alitajran
    X:          x.com/alitajran

    - Exclude users that you don’t want the script to run against. Add them in line 35. If you don’t need this feature, comment out line 38.
    - Change permission that you want to set for all the users in line 41.

    .CHANGELOG
    V1.30, 02/19/2025 - It will now get the calendar folder name language for each mailbox.
#>

# Start transcript
Start-Transcript -Path "C:\temp\Set-DefCalPermissions.log" -Append

# Set scope to entire forest. Cmdlet only available for Exchange on-premises.
#Set-ADServerSettings -ViewEntireForest $true

# Get all user mailboxes
$Users = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

# Users exception (add the UserPrincipalName)
$Exception = @("irene.springer@exoip.com", "richard.grant@exoip.com")

# Permissions
$Permission = "LimitedDetails"

# Loop through each user
foreach ($User in $Users) {
    # Get calendar folders for the user
    $Calendars = Get-MailboxFolderStatistics $User.UserPrincipalName -FolderScope Calendar | Where-Object { $_.FolderType -eq "Calendar" }

    # Leave permissions if user is exception
    if ($Exception -Contains ($User.UserPrincipalName)) {
        Write-Host "$User is an exception, don't touch permissions" -ForegroundColor Red
    }
    else {
        # Loop through each user calendar
        foreach ($Calendar in $Calendars) {
            $CalendarName = $Calendar.Name
            $Cal = "$($User.UserPrincipalName):\$CalendarName"
            $CurrentMailFolderPermission = Get-MailboxFolderPermission -Identity $Cal -User Default

            # Update calendar permissions if necessary
            if ($CurrentMailFolderPermission.AccessRights -ne "$Permission") {
                # Set calendar permission / Remove -WhatIf parameter after testing
                Set-MailboxFolderPermission -Identity $Cal -User Default -AccessRights $Permission -WarningAction:SilentlyContinue -WhatIf
                Write-Host $User.DisplayName added permissions $Permission -ForegroundColor Green
            }
            else {
                Write-Host $User.DisplayName already has the permission $Permission -ForegroundColor Yellow
            }
        }
    }
}

Stop-Transcript
