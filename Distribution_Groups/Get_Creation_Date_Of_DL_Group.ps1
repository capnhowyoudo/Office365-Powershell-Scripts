<#
.SYNOPSIS
Retrieve the creation date of a specific distribution group.

.DESCRIPTION
This command fetches the `WhenCreated` property of a distribution group in Exchange Online.
Replace the Identity with the desired distribution group's email address.

.NOTES
- Requires Exchange Online module to be connected.
- Use a generic email for documentation purposes.
- Example output shows when the group was created.
#>

# Example using a generic email
Get-DistributionGroup -Identity "usergroup@domain.com" | Select-Object WhenCreated
