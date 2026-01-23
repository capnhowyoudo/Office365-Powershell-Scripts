<#
.SYNOPSIS
Backs up Microsoft 365 group members and optionally removes all non-owner members from the group.

.DESCRIPTION
This script connects to Microsoft Graph, locates a specified Microsoft 365 group by display name or email,
retrieves all owners and members, exports a backup of the group membership to a CSV file, and then
removes all members who are not owners. A simulation mode is available to preview changes without
performing deletions.

.NOTES
Required Module:
- Microsoft.Graph

Required Permissions:
- GroupMember.ReadWrite.All
- Group.Read.All
- User.Read.All

To perform actual deletions, set the $Simulate variable to $false.
#>

# 1. Connect to Microsoft Graph
Connect-MgGraph -Scopes "GroupMember.ReadWrite.All", "Group.Read.All", "User.Read.All"

# 2. Configuration
$GroupIdentifier = "marketing@yourdomain.com" 
$Folder = "C:\temp"
$BackupPath = "$Folder\GroupBackup_$(Get-Date -Format 'yyyyMMdd_HHmm').csv"
$Simulate = $true  # Set to $false to perform actual deletion

# 3. Ensure the temp folder exists
if (!(Test-Path $Folder)) { New-Item -ItemType Directory -Path $Folder | Out-Null }

# 4. Get the group
$Group = Get-MgGroup -Filter "DisplayName eq '$GroupIdentifier' or mail eq '$GroupIdentifier'"
if ($null -eq $Group) {
    Write-Host "Group '$GroupIdentifier' not found." -ForegroundColor Red
    return
}

# 5. Fetch Owners and Members with explicit properties
$OwnerIds = (Get-MgGroupOwner -GroupId $Group.Id).Id

# We use -All and ExpandProperty to ensure we get the user details correctly
$AllMembers = Get-MgGroupMember -GroupId $Group.Id -All | ForEach-Object {
    Get-MgUser -UserId $_.Id -Property "Id","DisplayName","UserPrincipalName"
}

# 6. Create Backup CSV
Write-Host "Backing up members to $BackupPath..." -ForegroundColor Cyan
$AllMembers | Select-Object Id, DisplayName, UserPrincipalName, @{Name="IsOwner"; Expression={$OwnerIds -contains $_.Id}} | Export-Csv -Path $BackupPath -NoTypeInformation

Invoke-Item $Folder

# 7. Removal Process
if ($Simulate) { Write-Host "--- SIMULATION MODE ---" -ForegroundColor Cyan }

foreach ($Member in $AllMembers) {
    if ($OwnerIds -notcontains $Member.Id) {
        if ($Simulate) {
            Write-Host "[WhatIf] Would remove: $($Member.DisplayName) ($($Member.UserPrincipalName))" -ForegroundColor Gray
        } else {
            try {
                Remove-MgGroupMemberByRef -GroupId $Group.Id -DirectoryObjectId $Member.Id
                Write-Host " - Removed: $($Member.DisplayName)" -ForegroundColor Yellow
            }
            catch {
                Write-Host " - Error removing $($Member.DisplayName)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host " - Kept Owner: $($Member.DisplayName)" -ForegroundColor Green
    }
}
