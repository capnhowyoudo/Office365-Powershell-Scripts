<#
.SYNOPSIS
Update the recipient filter for a Dynamic Distribution Group.

.DESCRIPTION
This script modifies the RecipientFilter of a Dynamic Distribution Group (DDG) in Exchange Online or Exchange On-Premises.
The filter determines which recipients are included in the dynamic group. 
In this example, the filter includes all user mailboxes except those whose Name contains "Employment".

.NOTES
- Replace "All Staff" with the name of your Dynamic Distribution Group.
- Modify the RecipientFilter logic as needed to include/exclude specific recipients.
- Example filter syntax: 
    {((RecipientType -eq 'UserMailbox') -and -not(Name -like 'Employment'))}
- This cmdlet requires the Exchange Online Management module or Exchange Management Shell.
#>

# Variables
$DynamicGroupName = "All Staff"
$RecipientFilter = {((RecipientType -eq 'UserMailbox') -and -not(Name -like 'Employment'))}

# Update Dynamic Distribution Group
Set-DynamicDistributionGroup -Identity $DynamicGroupName -RecipientFilter $RecipientFilter
