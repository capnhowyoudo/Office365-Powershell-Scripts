<#
.SYNOPSIS
Retrieves public folders from the Exchange public folder hierarchy.

.DESCRIPTION
This command queries Exchange to display public folders within the organization.
It returns the public folder structure from the root of the public folder tree
and can be used to review folder names and hierarchy within the environment.

.NOTES
Generic example for listing public folders in Exchange.
#>

# Retrieve all public folders from the public folder hierarchy
Get-PublicFolder
