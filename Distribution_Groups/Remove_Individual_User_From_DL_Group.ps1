<#
.SYNOPSIS
Removes a member from a distribution group in Exchange Online or On-Premises.

.DESCRIPTION
This cmdlet removes a specified user from a distribution group. The group can be mail-enabled or a security-enabled distribution group.

.NOTES
- Replace $DistributionGroup with the target group name.
- Replace $Member with the user to remove.
- Can be used in both Exchange Online and Exchange On-Premises.
- Example:
    $DistributionGroup = "Support Team"
    $Member = "user@domain.com"
    Remove-DistributionGroupMember -Identity $DistributionGroup -Member $Member -Confirm:$false
#>

# Variables
$DistributionGroup = "Support Team"
$Member = "user@domain.com"

# Remove member from distribution group
Remove-DistributionGroupMember -Identity $DistributionGroup -Member $Member -Confirm:$false
