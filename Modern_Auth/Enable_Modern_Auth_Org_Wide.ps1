<#
.SYNOPSIS
    Enables the OAuth 2.0 Client Profile setting for the entire organization.

.DESCRIPTION
    This command modifies the global Exchange Online configuration by setting the -OAuth2ClientProfileEnabled property to $True.
    This action is a critical, tenant-wide step required to fully enable and enforce Modern Authentication (OAuth 2.0) for Exchange services, ensuring client applications use contemporary, token-based security standards.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module.
    - Context: Security configuration and migration from Basic Authentication to Modern Authentication.
    - WARNING: This is a configuration change (Set-), not a read operation. It affects the entire organization.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Open PowerShell and authenticate to your tenant:
       Connect-ExchangeOnline

    2. Run the command below to enable the OAuth 2.0 Client Profile:
       Set-OrganizationConfig -OAuth2ClientProfileEnabled $True
    
    3. Use Get-OrganizationConfig to verify the change was successful.
#>

Set-OrganizationConfig -OAuth2ClientProfileEnabled $True
