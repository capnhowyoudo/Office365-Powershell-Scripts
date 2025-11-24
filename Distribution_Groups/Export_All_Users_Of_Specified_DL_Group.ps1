<#
.SYNOPSIS
Retrieve all members of a distribution group and export to CSV.

.DESCRIPTION
This cmdlet gets all members of a specified distribution group in Exchange Online or Exchange On-Premises
and exports the results to a CSV file for reporting or auditing purposes.

.NOTES
- Replace $DistributionGroup with the target group name.
- Replace $ExportPath with the desired file path for the CSV export.
- Example:
    $DistributionGroup = "Sales Team"
    $ExportPath = "C:\Temp\SalesTeamMembers.csv"
#>

# Variables
$DistributionGroup = "Marketing Team"
$ExportPath = "C:\Temp\DistributionGroupMembers.csv"

# Ensure folder exists
$Folder = Split-Path $ExportPath
if (-not (Test-Path $Folder)) { New-Item -Path $Folder -ItemType Directory -Force }

# Get members and export to CSV
Get-DistributionGroupMember -Identity $DistributionGroup | 
    Select-Object Name, PrimarySmtpAddress, RecipientType | 
    Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8

# Output to console
Get-DistributionGroupMember -Identity $DistributionGroup | 
    Select-Object Name, PrimarySmtpAddress, RecipientType | 
    Format-Table -AutoSize
