<#
.SYNOPSIS
Generates a report of mailbox permissions in Exchange Online for all users.

.DESCRIPTION
This script retrieves all mailbox permissions for each user in Exchange Online, including:
- Full Access permissions (excluding the mailbox owner)
- Send As permissions
- Send on Behalf Of permissions

It generates a CSV report containing the mailbox, user, permission type, and mailbox type. 
A progress bar is displayed during processing. The report is saved to C:\Temp\MailboxPermissionsReport.csv.

.NOTES
- Requires an active Exchange Online PowerShell session.
- Discovery Search Mailbox is excluded from the report.
- Ensure C:\Temp exists or the script will fail when exporting CSV.
- Replace example emails with your organization’s domain as needed.
- Reference: https://www.sharepointdiary.com/2021/11/check-mailbox-permissions-office-365.html
#>

# Step 1: Connect to Exchange Online
Connect-ExchangeOnline

# Step 2: Get All Mailboxes
$Mailboxes = Get-Mailbox -ResultSize Unlimited | Where {$_.DisplayName -ne "Discovery Search Mailbox"}
$ReportData = @()
$MailboxCount = $Mailboxes.Count

# Step 3: Gather Mailbox Permissions
$MailboxCounter = 0
ForEach ($Mailbox in $Mailboxes) {
    # Get All Full Permissions - excluding the mailbox owner
    $Permissions = Get-MailboxPermission -Identity $Mailbox.UserPrincipalName | Where {$_.User -ne "NT AUTHORITY\SELF"}  
    foreach ($Permission in $Permissions) {
        $info = New-Object PSObject -Property @{
            Mailbox        = $Mailbox.UserPrincipalName
            UserName       = $Mailbox.DisplayName
            UserID         = $Permission.User
            AccessRights   = $Permission | Select -ExpandProperty AccessRights
            MailboxType    = $Mailbox.RecipientTypeDetails
        }
        $ReportData += $info
    }

    # Get all "Send As" Permissions
    $SendAsPermissions = Get-RecipientPermission -Identity $Mailbox.UserPrincipalName | Where {$_.Trustee -ne "NT AUTHORITY\SELF"}
    ForEach ($Permission in $SendAsPermissions) {
        $info = New-Object PSObject -Property @{
            Mailbox      = $Mailbox.UserPrincipalName
            UserName     = $Mailbox.DisplayName
            UserID       = $Permission.Trustee
            AccessRights = $Permission | Select -ExpandProperty AccessRights
            MailboxType  = $Mailbox.RecipientTypeDetails
        }
        $ReportData += $info
    }

    # Get all "Send on Behalf Of" permissions
    If ($Mailbox.GrantSendOnBehalfTo -ne $null) {
        ForEach ($Permission in $Mailbox.GrantSendOnBehalfTo) {
            $info = New-Object PSObject -Property @{
                Mailbox      = $Mailbox.UserPrincipalName
                UserName     = $Mailbox.DisplayName
                UserID       = $Permission
                AccessRights = "Send on Behalf Of"
                MailboxType  = $Mailbox.RecipientTypeDetails
            }
            $ReportData += $info
        }
    }

    $MailboxCounter++
    $ProgressStatus = "$($Mailbox.UserPrincipalName) ($MailboxCounter of $MailboxCount)"
    Write-Progress -Activity "Processing Mailbox" -Status $ProgressStatus -PercentComplete (($MailboxCounter/$MailboxCount)*100)
}

# Step 4: Export Report to CSV
if (-not (Test-Path "C:\Temp")) { New-Item -Path "C:\Temp" -ItemType Directory -Force }
$ReportData | Export-Csv -Path "C:\Temp\MailboxPermissionsReport.csv" -NoTypeInformation
$ReportData | Format-Table -AutoSize

# Step 5: Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
