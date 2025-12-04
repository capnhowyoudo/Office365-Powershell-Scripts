<#
.SYNOPSIS
Exports all cloud-only (non–directory synchronized) Microsoft 365 users to a CSV file.

.DESCRIPTION
This script retrieves all Microsoft 365 users through Microsoft Graph and filters accounts
that are **not synchronized from on-premises Active Directory** (OnPremisesSyncEnabled = $null or False).  
It collects key attributes such as DisplayName, UserPrincipalName, and UserType.  

The results are displayed on screen and exported to a CSV file for reporting, auditing, or verification.
This replaces the legacy AzureAD command that used DirSyncEnabled.

.NOTES
Module Required:
    - Microsoft Graph PowerShell SDK
      Install using: Install-Module Microsoft.Graph

Permissions Required:
    - User.Read.All OR Directory.Read.All (Admin consent recommended)

Additional Notes:
    - OnPremisesSyncEnabled = $null or False indicates the user is cloud-only.
    - Useful for identifying cloud-only accounts for migration or auditing purposes.
    - Update the CSV file path to match your environment.
    - Replace user emails with generic placeholders if documenting.
#>

# Connect to Microsoft Graph
Connect-Graph -Scopes "User.Read.All","Directory.Read.All"

# Get cloud-only users
$CloudOnlyUsers = Get-MgUser -All -Property "DisplayName","UserPrincipalName","UserType","OnPremisesSyncEnabled" |
    Where-Object { $_.OnPremisesSyncEnabled -eq $null -or $_.OnPremisesSyncEnabled -eq $false } |
    Select-Object DisplayName, UserPrincipalName, UserType

# Display on screen
$CloudOnlyUsers | Format-Table -AutoSize

# Export to CSV
$CloudOnlyUsers | Export-Csv "C:\Temp\Non_Dir_synced.csv" -NoTypeInformation -Encoding UTF8
