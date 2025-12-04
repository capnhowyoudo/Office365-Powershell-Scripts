<#
.SYNOPSIS
Exports all directory-synchronized (AD Connect synced) Microsoft 365 groups to a CSV file.

.DESCRIPTION
This script retrieves all Microsoft 365 groups through Microsoft Graph and filters groups 
that are synchronized from on-premises Active Directory (OnPremisesSyncEnabled = True).  
It collects key attributes such as DisplayName, Description, and OnPremisesSyncEnabled.  

The results are displayed on screen and exported to a CSV file for reporting, auditing, or verification.  
This replaces the legacy AzureAD command that used DirSyncEnabled.

.NOTES
Module Required:
    - Microsoft Graph PowerShell SDK
      Install using: Install-Module Microsoft.Graph

Permissions Required:
    - Group.Read.All OR Directory.Read.All (Admin consent recommended)

Additional Notes:
    - OnPremisesSyncEnabled = True indicates the group is AD Connect synchronized.
    - Useful for auditing, migration, or verifying group sync status.
    - Update the CSV file path as needed.
#>

# Connect to Microsoft Graph
Connect-Graph -Scopes "Group.Read.All","Directory.Read.All"

# Get directory-synced groups
$DirSyncedGroups = Get-MgGroup -All -Property "DisplayName","Description","OnPremisesSyncEnabled" |
    Where-Object { $_.OnPremisesSyncEnabled -eq $true } |
    Select-Object DisplayName, Description, OnPremisesSyncEnabled

# Display on screen
$DirSyncedGroups | Format-Table -AutoSize

# Export to CSV
$DirSyncedGroups | Export-Csv "C:\Temp\Group_Dir_synced.csv" -NoTypeInformation -Encoding UTF8
