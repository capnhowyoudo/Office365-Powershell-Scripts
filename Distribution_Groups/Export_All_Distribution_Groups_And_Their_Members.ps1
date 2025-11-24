<#
.SYNOPSIS
Export members of all non-security distribution groups in Exchange Online to a CSV.

.DESCRIPTION
This script connects to Exchange Online, retrieves all non-security-enabled distribution groups,
collects the members of each group, and exports the details to a CSV file.
The exported CSV includes the group name, group email, member name, member email, and recipient type.

.NOTES
- The CSV file will be saved to "C:\Temp\UserDistributionLists.csv". Ensure the folder exists or adjust the path.
- Requires Exchange Online Management Module.
- Security groups are excluded from the export.
- Replace any placeholder emails with your actual domain or generic email if needed.
#>

# Connect to Exchange Online
Connect-ExchangeOnline -ShowBanner:$false

# Get all non-security distribution groups
$DistributionGroups = Get-DistributionGroup -ResultSize Unlimited | Where {!$_.GroupType.Contains("SecurityEnabled")}
$DLS = @()

# Collect members of each distribution group
$DistributionGroups | ForEach-Object {
    $Group = $_
    Get-DistributionGroupMember -Identity $Group.Name -ResultSize Unlimited | ForEach-Object {
        $Member = $_
        $DLS += [PSCustomObject]@{
            GroupName     = $Group.DisplayName
            GroupEmail    = $Group.PrimarySmtpAddress
            Member        = $Member.Name
            EmailAddress  = $Member.PrimarySmtpAddress
            RecipientType = $Member.RecipientType
        }
    }
}

# Export the distribution list membership report to CSV
$DLS | Export-CSV -Path "C:\Temp\UserDistributionLists.csv" -NoTypeInformation
