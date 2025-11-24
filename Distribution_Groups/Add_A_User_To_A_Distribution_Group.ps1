<#
.SYNOPSIS
Add a member to a distribution group.

.DESCRIPTION
This command adds a specified user to a distribution group in Exchange Online.
Replace the Identity with the target distribution group and Member with the user’s email address.

.NOTES
- Requires Exchange Online module to be connected.
- Use a generic email for documentation purposes.
- You can add multiple members by running the command multiple times or looping through a CSV file.
#>

# Example using generic emails
Add-DistributionGroupMember -Identity "Staff" -Member "user@domain.com"
