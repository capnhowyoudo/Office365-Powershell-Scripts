<#
.SYNOPSIS
Retrieves the current organization-wide configuration settings.

.DESCRIPTION
This command returns the overall organizational configuration from the messaging
environment, including global settings related to features, policies, and service
behavior. It is commonly used for auditing or reviewing environment-wide defaults.

.NOTES
No parameters are required. This retrieves the configuration for the entire organization.
#>

Get-OrganizationConfig
