<#
.SYNOPSIS
    Exports Microsoft 365 users assigned to a specific SKU to a CSV file.

.DESCRIPTION
    This script connects to Microsoft Graph, identifies users with a specific SkuId, 
    and exports their DisplayName, Mail, and the License Name to C:\temp.

.NOTES
    To retrieve a list of available SkuIds and names in your tenant, run:
    Get-MgSubscribedSku | Select-Object SkuId, SkuPartNumber
#>

# Connect to Microsoft Graph with required scopes
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"

# Variables
$SkuId = "3dd6cf57-d688-4eed-ba52-9e40b5468c3e"
$LicenseName = "THREAT_INTELLIGENCE_P2"
$ExportPath = "C:\temp\$($LicenseName)_users.csv"

# Ensure directory exists
if (!(Test-Path "C:\temp")) { New-Item -Path "C:\temp" -ItemType Directory -Force }

# Process users and export
Get-MgUser -All -Property DisplayName, Mail, AssignedLicenses | Where-Object {
    $_.AssignedLicenses.SkuId -contains $SkuId
} | Select-Object DisplayName, Mail, @{Name="LicenseName"; Expression={$LicenseName}} | 
Export-Csv -Path $ExportPath -NoTypeInformation
