<#
.SYNOPSIS
    Exports Microsoft 365 licensed users to a CSV file using Microsoft Graph.

.DESCRIPTION
    This script retrieves all users in a Microsoft 365 tenant who have at least one license assigned. 
    It translates the GUID-based SkuIds into human-readable names (e.g., SPE_E5) and exports 
    the data to a CSV where each license is placed in its own numbered column (License1, License2, etc.).

.NOTES
    Required Permissions: User.Read.All, Organization.Read.All
    Dependencies: Microsoft.Graph PowerShell Module
#>

# Prerequisites: 
# Install-Module Microsoft.Graph -Scope CurrentUser

# Ensure Export Directory Exists
$ExportDir = "C:\Temp"
if (-not (Test-Path -Path $ExportDir)) {
    New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
}

Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All"

$ExportPath = Join-Path $ExportDir "M365LicensedUsers_SplitColumns.csv"

# Fetch all Subscribed Skus for readable names
$SkuLookup = Get-MgSubscribedSku | Select-Object SkuId, SkuPartNumber

# Fetch licensed users
$LicensedUsers = Get-MgUser -Filter "assignedLicenses/`$count ne 0" -ConsistencyLevel eventual -CountVariable UserCount -All -Property Id, DisplayName, UserPrincipalName, AssignedLicenses

$Results = foreach ($User in $LicensedUsers) {
    # Create the base object
    $Properties = [ordered]@{
        DisplayName       = $User.DisplayName
        UserPrincipalName = $User.UserPrincipalName
    }

    # Iterate through licenses and add them as License1, License2, etc.
    $i = 1
    foreach ($License in $User.AssignedLicenses) {
        $FriendlyName = ($SkuLookup | Where-Object { $_.SkuId -eq $License.SkuId }).SkuPartNumber
        # If a name isn't found in the lookup, fall back to the SkuId
        $Value = if ($FriendlyName) { $FriendlyName } else { $License.SkuId }
        
        $Properties.Add("License$i", $Value)
        $i++
    }

    [PSCustomObject]$Properties
}

# Export to CSV
$Results | Export-Csv -Path $ExportPath -NoTypeInformation

Write-Host "Export complete with split columns: $ExportPath"
