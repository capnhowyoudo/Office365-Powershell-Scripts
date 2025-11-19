<#
.SYNOPSIS
Displays whether Auto-Expanding Archive is enabled for the entire organization.
#>

Get-OrganizationConfig | FL AutoExpandingArchiveEnabled
