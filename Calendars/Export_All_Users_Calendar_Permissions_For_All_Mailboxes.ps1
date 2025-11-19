<#
.SYNOPSIS
Exports calendar folder permissions for all user mailboxes to a CSV file.

.DESCRIPTION
This script retrieves all mailboxes in the organization, iterates through each mailbox, 
and collects the calendar folder permissions. It then exports the results to a CSV file 
with the mailbox display name, user, and assigned permissions.

.NOTES
• CSV file path: C:\Temp\CalendarPermissions.CSV
• If C:\Temp does not exist, it will be created automatically.
• Use this to audit calendar permissions across the organization.
• Progress is displayed in the console during processing.
#>

$exportPath = "C:\Temp\CalendarPermissions.CSV"

# Create folder if it doesn't exist
$folder = Split-Path $exportPath
if (-not (Test-Path $folder)) {
    New-Item -Path $folder -ItemType Directory | Out-Null
}

$Result = @()
$allMailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object -Property DisplayName, PrimarySMTPAddress
$totalMailboxes = $allMailboxes.Count
$i = 1 

$allMailboxes | ForEach-Object {
    $mailbox = $_
    Write-Progress -Activity "Processing $($_.DisplayName)" -Status "$i out of $totalMailboxes completed"
    
    $folderPerms = Get-MailboxFolderPermission -Identity "$($_.PrimarySMTPAddress):\Calendar"
    $folderPerms | ForEach-Object {
        $Result += New-Object PSObject -Property @{ 
            MailboxName = $mailbox.DisplayName
            User        = $_.User
            Permissions = $_.AccessRights
        }
    }
    $i++
}

$Result | Select-Object MailboxName, User, Permissions |
Export-CSV $exportPath -NoTypeInformation -Encoding UTF8
