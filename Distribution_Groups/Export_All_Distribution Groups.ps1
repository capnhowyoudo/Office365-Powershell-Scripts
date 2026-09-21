<#
.SYNOPSIS
    Lists all distribution groups and Microsoft 365 (Unified) groups in Exchange Online.

.DESCRIPTION
    Connects to Exchange Online, retrieves all Distribution Groups, Mail-Enabled Security
    Groups, and Microsoft 365 Groups, displays them in a formatted table, and exports both
    a distribution-groups-only CSV and a combined CSV (DLs + M365 Groups) to C:\Temp.

.NOTES
    Requires an active connection to Exchange Online and read access to recipient objects.
    Creates C:\Temp if it doesn't already exist.
#>

# Ensure the output folder exists
$OutputFolder = "C:\Temp"
if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory | Out-Null
}

# Connect to Exchange Online (if not already connected)
Connect-ExchangeOnline

# Get all Distribution Groups / Mail-Enabled Security Groups
$DLs = Get-DistributionGroup -ResultSize Unlimited |
    Select-Object DisplayName, PrimarySmtpAddress, RecipientTypeDetails, Guid, ManagedBy

# Display Distribution Groups in console
$DLs | Sort-Object DisplayName | Format-Table -AutoSize

# Export Distribution Groups only
$DLs | Sort-Object DisplayName |
    Export-Csv -Path "$OutputFolder\AllDistributionLists.csv" -NoTypeInformation

# Get all Microsoft 365 (Unified) Groups
$M365Groups = Get-UnifiedGroup -ResultSize Unlimited |
    Select-Object DisplayName, PrimarySmtpAddress, RecipientTypeDetails, Guid, ManagedBy

# Combine DLs + M365 Groups and export
$All = $DLs + $M365Groups
$All | Sort-Object DisplayName |
    Export-Csv -Path "$OutputFolder\AllGroups.csv" -NoTypeInformation

Write-Host "Done. Files saved to $OutputFolder\AllDistributionLists.csv and $OutputFolder\AllGroups.csv" -ForegroundColor Green
