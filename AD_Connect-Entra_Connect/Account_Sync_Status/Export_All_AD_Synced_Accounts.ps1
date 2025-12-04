<#
.SYNOPSIS
Exports all directory-synchronized (AD Connect synced) Microsoft 365 users to a CSV file using Microsoft Graph PowerShell.

.DESCRIPTION
This script retrieves all users from Microsoft Graph and filters accounts that were synchronized
from on-premises Active Directory (OnPremisesSyncEnabled = True). It exports important attributes,
such as DisplayName, UserPrincipalName, OnPremisesSyncEnabled status, and the time of the last directory sync,
when available.

This version replaces AzureAD module usage and uses the modern Microsoft Graph PowerShell SDK.

.NOTES
Module Required:
    - Microsoft Graph PowerShell SDK  
      Install using: Install-Module Microsoft.Graph

Permissions Required:
    - User.Read.All OR Directory.Read.All (Admin consent recommended)

Additional Notes:
    - OnPremisesSyncEnabled = True indicates the account is synced from on-prem AD.
    - LastDirSyncTime is available only when using Directory Objects (not all accounts report it).
    - This script is the Microsoft Graph replacement for:
        Get-AzureADUser -All $true | Where {$_.DirSyncEnabled -eq $true}
    - To view all synchronized users without exporting:
        Get-MgUser -All | Where-Object {$_.OnPremisesSyncEnabled -eq $true}
    - Replace the export path as needed.
#>

# Connect to Graph
Connect-Graph -Scopes "User.Read.All","Directory.Read.All"

# Retrieve synced users with required properties
$SyncedUsers = Get-MgUser -All -Property "DisplayName","UserPrincipalName","OnPremisesSyncEnabled","OnPremisesLastSyncDateTime" |
    Where-Object { $_.OnPremisesSyncEnabled -eq $true } |
    Select-Object DisplayName, UserPrincipalName, OnPremisesSyncEnabled, OnPremisesLastSyncDateTime

# Display results on screen
$SyncedUsers | Format-Table -AutoSize

# Export clean CSV
$SyncedUsers | Export-Csv "C:\Temp\Dir_synced.csv" -NoTypeInformation -Encoding UTF8
