<#
.SYNOPSIS
Exports Microsoft 365 groups with disabled members to a CSV file.

.DESCRIPTION
This script connects to Microsoft Graph, retrieves all groups and all disabled users,
then identifies which disabled users belong to which groups. The results are exported
to a CSV file located at C:\Temp\DisabledMembers.csv. This is useful for auditing inactive or disabled accounts.

.NOTES
Output CSV path: C:\Temp\test.csv
Requires Microsoft Graph PowerShell module.
Example usage:
    .\Export_Disabled_Group_Members_From_Groups.ps1

.PARAMETER None
This script has no parameters.

#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All" -NoWelcome

# Get all disabled users
$disabledUsers = Get-MgUser -All -Filter "accountEnabled eq false"

# Get all groups
$allGroups = Get-MgGroup -All

# Initialize results array
$results = @()

# Loop through groups and check for disabled members
$allGroups | ForEach-Object {
    $group = $_
    $groupMembers = Get-MgGroupMember -GroupId $group.Id
    $disabledMembers = $disabledUsers | Where-Object { $groupMembers.Id -contains $_.Id }
    
    if ($disabledMembers.Count -gt 0) {
        foreach ($member in $disabledMembers) {
            $results += [pscustomobject]@{
                "Group Name"          = $group.DisplayName
                "Group Mail"          = $group.Mail
                "Disabled User Name"  = $member.DisplayName
                "User Principal Name" = $member.UserPrincipalName
            }
        }
    }
}

# Export results to CSV
$results | Export-Csv "C:\Temp\DisabledMembers.csv" -NoTypeInformation
