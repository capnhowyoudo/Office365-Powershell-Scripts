<#
.SYNOPSIS
    Retrieves the organization's name and all OAuth/Modern Authentication settings in a formatted table.

.DESCRIPTION
    This command retrieves the comprehensive configuration object for the entire Exchange Online organization using Get-OrganizationConfig.
    It then pipes the single configuration object to Format-Table to display only the 'Name' property and any properties beginning with 'OAuth*' (a wildcard).
    The -Auto switch ensures that the table columns are sized appropriately, which is typically used for verifying the status of Modern Authentication features.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module.
    - Context: Reviewing global tenant settings, particularly for authentication features.
    - The wildcard 'OAuth*' is used to select all properties that start with 'OAuth' without typing them all out.

    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Open PowerShell and authenticate to your tenant:
       Connect-ExchangeOnline

    2. Run the command below to see the status of OAuth settings in a clean table:
       Get-OrganizationConfig | Format-Table Name,OAuth* -Auto
#>

Get-OrganizationConfig | Format-Table Name,OAuth* -Auto
