<#
.SYNOPSIS
Displays Microsoft 365 subscription SKU license totals and usage.

.DESCRIPTION
Retrieves subscribed SKUs from Microsoft Graph and shows a formatted table
containing the SKU part number, total enabled licenses, and consumed licenses.

.NOTES
Requires connection to Microsoft Graph with appropriate permissions.
Example:
Connect-MgGraph -Scopes "Organization.Read.All"
#>

Get-MgSubscribedSku | Select-Object SkuPartNumber, @{n='Total';e={$_.PrepaidUnits.Enabled}}, @{n='Used';e={$_.ConsumedUnits}} | FT -AutoSize
