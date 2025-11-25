<#
.SYNOPSIS
    Disables the OAuth 2.0 Client Profile setting for the entire organization.

.DESCRIPTION
    This command modifies the global Exchange Online configuration by setting the -OAuth2ClientProfileEnabled property to $False.
    This action effectively disables the use of the OAuth 2.0 Client Profile. As this moves the organization away from the current security standard of Modern Authentication, this command is typically reserved for specific troubleshooting or rollback scenarios only.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module.
    - Context: Security configuration, disabling Modern Authentication features (generally discouraged).
    - WARNING: Disabling this feature may impact client connectivity and revert security standards. Use with caution.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Open PowerShell and authenticate to your tenant:
       Connect-ExchangeOnline

    2. Run the command below to disable the OAuth 2.0 Client Profile:
       Set-OrganizationConfig -OAuth2ClientProfileEnabled $False
    
    3. Use Get-OrganizationConfig to verify the change was successful.
#>

Set-OrganizationConfig -OAuth2ClientProfileEnabled $False
