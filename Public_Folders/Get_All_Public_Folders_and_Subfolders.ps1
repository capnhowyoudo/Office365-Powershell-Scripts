<#
.SYNOPSIS
Retrieves all public folders recursively and displays their identity and name.

.DESCRIPTION
This command queries Exchange to list all public folders in the hierarchy using
the -Recurse parameter. It returns each folder’s full identity path along with
its display name, allowing administrators to review the entire public folder
structure within the environment.

.NOTES
Generic example for listing the full public folder hierarchy.
#>

# Retrieve all public folders recursively and display their identity and name
Get-PublicFolder -Recurse | Select-Object Identity, Name
