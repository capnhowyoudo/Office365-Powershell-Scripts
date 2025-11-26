<#
.SYNOPSIS
Exports all Microsoft 365 Groups and their Members to a CSV file using Microsoft Graph PowerShell.

.DESCRIPTION
This script connects to Microsoft Graph, retrieves all Microsoft 365 groups, enumerates their members, 
collects detailed user information, and exports the results to a CSV file. 
The CSV output is saved to C:\Temp\M365GroupMembers.csv.
Supports progress tracking and handles empty groups gracefully.

.NOTES
CSV file path is set to C:\Temp\M365GroupMembers.csv.
Parameters retrieved for users: Id, DisplayName, UserPrincipalName, UserType, AccountEnabled.
Requires Microsoft Graph PowerShell module.
Example usage:
    .\Export_M365_All_Groups_And_Members.ps1

.PARAMETER CsvPath
Optional: Path to export CSV. Default is C:\Temp\M365GroupMembers.csv.
Example:
    .\Export_M365_All_Groups_And_Members.ps1 -CsvPath "C:\Temp\CustomReport.csv"

.LINK
www.alitajran.com/export-microsoft-365-group-members-to-csv-powershell/

.CHANGELOG
V1.00, 03/18/2024 - Initial version
#>

# CSV file path to export
$CsvPath = "C:\Temp\M365GroupMembers.csv"

# Connect to Microsoft Graph with required scopes
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All"

# Retrieve all groups
$groups = Get-MgGroup -All

# Properties to fetch for each user
$Properties = @(
    'Id', 'DisplayName', 'UserPrincipalName', 'UserType', 'AccountEnabled'
)

# Initialize a list to store report objects
$Report = [System.Collections.Generic.List[Object]]::new()

# Track progress
$totalGroups = $groups.Count
$currentGroup = 0

# Loop through each group
foreach ($group in $groups) {
    # Retrieve group members
    $members = Get-MgGroupMember -GroupId $group.id -All

    # Determine group type
    $groupType = if ($group.groupTypes -eq "Unified" -and $group.securityEnabled) { "Microsoft 365 (security-enabled)" }
    elseif ($group.groupTypes -eq "Unified" -and !$group.securityEnabled) { "Microsoft 365" }
    elseif (!($group.groupTypes -eq "Unified") -and $group.securityEnabled -and $group.mailEnabled) { "Mail-enabled security" }
    elseif (!($group.groupTypes -eq "Unified") -and $group.securityEnabled) { "Security" }
    elseif (!($group.groupTypes -eq "Unified") -and $group.mailEnabled) { "Distribution" }
    else { "N/A" }

    # Handle groups with no members
    if ($members.Count -eq 0) {
        $ReportLine = [PSCustomObject][ordered]@{
            GroupId            = $group.Id
            GroupDisplayName   = $group.DisplayName
            GroupType          = $groupType
            UserDisplayName    = "N/A"
            UserPrincipalName  = "N/A"
            UserAlias          = "N/A"
            UserType           = "N/A"
            UserAccountEnabled = "N/A"
        }
        $Report.Add($ReportLine)
    }
    else {
        foreach ($member in $members) {
            $user = Get-MgUser -UserId $member.Id -Property $Properties -ErrorAction SilentlyContinue | Select-Object $Properties

            if ($user.Count -ne 0) {
                $alias = $user.UserPrincipalName.Split("@")[0]

                $ReportLine = [PSCustomObject][ordered]@{
                    GroupId            = $group.Id
                    GroupDisplayName   = $group.DisplayName
                    GroupType          = $groupType
                    UserDisplayName    = $user.DisplayName
                    UserPrincipalName  = $user.UserPrincipalName
                    UserAlias          = $alias
                    UserType           = $user.UserType
                    UserAccountEnabled = $user.AccountEnabled
                }

                $Report.Add($ReportLine)
            }
        }
    }

    # Update progress bar
    $currentGroup++
    $status = "{0:N0}" -f ($currentGroup / $totalGroups * 100)
    Write-Progress -Activity "Retrieving Group Members" -Status "Processing group: $($group.DisplayName) - $currentGroup of $totalGroups : $status% completed" -PercentComplete ($currentGroup / $totalGroups * 100)
}

# Complete progress
Write-Progress -Activity "Retrieving Group Members" -Completed

# Export report to CSV
$Report | Sort-Object GroupDisplayName | Export-Csv $CsvPath -NoTypeInformation -Encoding utf8
