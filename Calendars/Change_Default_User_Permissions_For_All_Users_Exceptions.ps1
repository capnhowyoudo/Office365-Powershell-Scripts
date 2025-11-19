<#
    .SYNOPSIS
    Change_Default_User_Permissions_For_All_Users_Exceptions.ps1

    .DESCRIPTION
    Set default calendar permissions for all user mailboxes including exception for users.

    Create Folder on C:\ named "Temp" for log file

    Note: The -WhatIf parameter is added in the script on line 65. If you run the script, nothing will happen in the environment. Instead, you get an output showing what will happen.
   
    Remove the -WhatIf parameter from the PowerShell script and rerun the script to set the default calendar sharing permissions for all users.

    Exclude users that you don’t want the script to run against. Add them in line 35. If you don’t need this feature, comment out lines 35, 50, 51, 52, 53, and 77

    Calendars are not always set in the English language. For example, in The Netherlands, it’s named Agenda. The script will check for the calendar names defined in line 41

    The output will show in the Windows PowerShell console. Not only that, it will show the output in a log because a transcript is added to the PS script. Go to the C:\temp folder and open the Set-DefCalPermissions.log file

    .The script works for:
    -Exchange On-Premises (Run Exchange Management Shell)
    -Exchange Online (Connect to Exchange Online PowerShell)

    .LINK
    alitajran.com/set-default-calendar-permissions-for-all-users-powershell

    .NOTES
    Written by: ALI TAJRAN
    Website:    alitajran.com
    LinkedIn:   linkedin.com/in/alitajran

    .CHANGELOG
    V1.00, 02/28/2021 - Initial version
    V1.10, 03/29/2023 - Changed Exceptions to look for UserPrincipalName
    
- AccessRights: Defines the permission level. Common values include:
    • Owner – Full control, including manage permissions
    • PublishingEditor – Read, create, modify, delete items/subfolders
    • Editor – Read, create, modify, delete items
    • PublishingAuthor – Read, create all items/subfolders, modify/delete own items
    • Author – Create/read items, modify/delete own items
    • NonEditingAuthor – Read all, create items, delete own items only
    • Reviewer – Read only
    • Contributor – Create items and folders only
    • AvailabilityOnly – Free/busy information
    • LimitedDetails – View subject/location only
    • None – No access
    
#>

# Start transcript
Start-Transcript -Path "C:\temp\Set-DefCalPermissions.log" -Append

# Set scope to entire forest. Cmdlet only available for Exchange on-premises.
#Set-ADServerSettings -ViewEntireForest $true

# Get all user mailboxes
$Users = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox

# Users exception (add the UserPrincipalName)
$Exception = @("youremail@exception.com", "youremail2@exception.com")

# Permissions
$Permission = "LimitedDetails"

# Calendar name languages
$FolderCalendars = @("Agenda", "Calendar", "Calendrier", "Kalender", "日历")

# Loop through each user
foreach ($User in $Users) {

    # Get calendar in every user mailbox
    $Calendars = (Get-MailboxFolderStatistics $User.UserPrincipalName -FolderScope Calendar)

    # Leave permissions if user is exception
    if ($Exception -Contains ($User.UserPrincipalName)) {
        Write-Host "$User is an exception, don't touch permissions" -ForegroundColor Red
    }
    else {

        # Loop through each user calendar
        foreach ($Calendar in $Calendars) {
            $CalendarName = $Calendar.Name

            # Check if calendar exist
            if ($FolderCalendars -Contains $CalendarName) {
                $Cal = "$($User.UserPrincipalName):\$CalendarName"
                $CurrentMailFolderPermission = Get-MailboxFolderPermission -Identity $Cal -User Default
                
                # Set calendar permission / Remove -WhatIf parameter after testing
                Set-MailboxFolderPermission -Identity $Cal -User Default -AccessRights $Permission -WarningAction:SilentlyContinue -WhatIf
                
                # Write output
                if ($CurrentMailFolderPermission.AccessRights -eq "$Permission") {
                    Write-Host $User.DisplayName already has the permission $CurrentMailFolderPermission.AccessRights -ForegroundColor Yellow
                }
                else {
                    Write-Host $User.DisplayName added permissions $Permission -ForegroundColor Green
                }
            }
        }
    }
}

Stop-Transcript
