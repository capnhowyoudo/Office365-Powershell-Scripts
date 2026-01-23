<#
.SYNOPSIS
Bulk backs up and optionally removes non-owner members from multiple Microsoft 365 groups.

.DESCRIPTION
This script connects to Microsoft Graph and processes a list of Microsoft 365 groups provided
via a TXT or CSV file. For each group, it retrieves owners and members, creates a CSV backup
of the membership, and removes all members who are not owners. A simulation mode is available
to safely preview changes before performing actual deletions.

.NOTES
Required Module:
- Microsoft.Graph

Required Permissions:
- GroupMember.ReadWrite.All
- Group.Read.All
- User.Read.All

Input File:
- TXT file containing one group display name or email per line
- CSV file containing a column named 'GroupName'

To perform actual deletions, set the $Simulate variable to $false.
#>

# 1. Connect to Microsoft Graph
Connect-MgGraph -Scopes "GroupMember.ReadWrite.All", "Group.Read.All", "User.Read.All"

# 2. Configuration
$InputFile = "C:\temp\groups.txt" # Change to .csv if using CSV
$Folder = "C:\temp"
$Simulate = $true  # Set to $false to perform actual deletion

# 3. Load Group List
if (!(Test-Path $InputFile)) {
    Write-Host "Input file not found at $InputFile" -ForegroundColor Red
    return
}

# Determine if input is CSV or TXT
if ($InputFile -like "*.csv") {
    $GroupList = (Import-Csv $InputFile).GroupName
} else {
    $GroupList = Get-Content $InputFile
}

# 4. Process Each Group
foreach ($GroupIdentifier in $GroupList) {
    Write-Host "`n--- Processing Group: $GroupIdentifier ---" -ForegroundColor Cyan
    
    # Get the group
    $Group = Get-MgGroup -Filter "DisplayName eq '$GroupIdentifier' or mail eq '$GroupIdentifier'"
    if ($null -eq $Group) {
        Write-Host "Group '$GroupIdentifier' not found. Skipping..." -ForegroundColor Red
        continue
    }

    $BackupPath = "$Folder\Backup_$($Group.DisplayName)_$(Get-Date -Format 'yyyyMMdd').csv"

    # 5. Fetch Owners and Members (Ensuring DisplayName is caught)
    $OwnerIds = (Get-MgGroupOwner -GroupId $Group.Id).Id
    $AllMembers = Get-MgGroupMember -GroupId $Group.Id -All | ForEach-Object {
        Get-MgUser -UserId $_.Id -Property "Id","DisplayName","UserPrincipalName"
    }

    # 6. Create Backup
    $AllMembers | Select-Object Id, DisplayName, UserPrincipalName, `
        @{Name="IsOwner"; Expression={$OwnerIds -contains $_.Id}} | 
        Export-Csv -Path $BackupPath -NoTypeInformation

    # 7. Removal Logic
    foreach ($Member in $AllMembers) {
        if ($OwnerIds -notcontains $Member.Id) {
            if ($Simulate) {
                Write-Host "[WhatIf] Would remove: $($Member.DisplayName)" -ForegroundColor Gray
            } else {
                try {
                    Remove-MgGroupMemberByRef -GroupId $Group.Id -DirectoryObjectId $Member.Id
                    Write-Host " - Removed: $($Member.DisplayName)" -ForegroundColor Yellow
                } catch {
                    Write-Host " - Error removing $($Member.DisplayName)" -ForegroundColor Red
                }
            }
        } else {
            Write-Host " - Kept Owner: $($Member.DisplayName)" -ForegroundColor Green
        }
    }
}

Invoke-Item $Folder
Write-Host "`nBulk process complete." -ForegroundColor White
