<#
.SYNOPSIS
Exports all cloud-only (non–directory synchronized) Microsoft 365 groups to a CSV file.

.DESCRIPTION
This script retrieves all Microsoft 365 groups through Microsoft Graph and filters groups 
that are **not synchronized from on-premises Active Directory** (OnPremisesSyncEnabled = $null or False).  
It collects key attributes such as DisplayName and Description.  

The results are displayed on screen and exported to a CSV file for reporting, auditing, or verification.  
This replaces the legacy AzureAD command that used DirSyncEnabled.

.NOTES
Module Required:
    - Microsoft Graph PowerShell SDK
      Install using: Install-Module Microsoft.Graph

Permissions Required:
    - Group.Read.All OR Directory.Read.All (Admin consent recommended)

Additional Notes:
    - OnPremisesSyncEnabled = $null or False indicates the group is cloud-only.
    - Useful for auditing, migration, or verifying group sync status.
    - Update the CSV file path as needed.
#>

# Connect to Microsoft Graph
Connect-Graph -Scopes "Group.Read.All","Directory.Read.All"

# Get cloud-only groups
$CloudOnlyGroups = Get-MgGroup -All -Property "DisplayName","Description","OnPremisesSyncEnabled" |
    Where-Object { $_.OnPremisesSyncEnabled -eq $null -or $_.OnPremisesSyncEnabled -eq $false } |
    Select-Object DisplayName, Description

# Display on screen
$CloudOnlyGroups | Format-Table -AutoSize

# Export to CSV
$CloudOnlyGroups | Export-Csv "C:\Temp\Non_Group_Dir_synced.csv" -NoTypeInformation -Encoding UTF8
