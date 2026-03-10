<#
.SYNOPSIS
    Retrieves the current Information Rights Management (IRM) settings for the Exchange Online tenant.

.DESCRIPTION
    This command is used to audit the IRM state. It reveals whether Azure RMS 
    is enabled, if internal/external licensing is active, and if the 
    simplified "Protect" button is visible to users in Outlook on the Web.

.NOTES
    - PREREQUISITE: Must be connected via 'Connect-ExchangeOnline'.
    - AUDIT FOCUS: Look specifically at 'AzureRMSLicensingEnabled' and 
      'InternalLicensingEnabled' to ensure they are set to True.
    - AUTHOR: Adapted for VisualFusion Environment.
#>

# View the full IRM configuration
Get-IRMConfiguration | Select-Object AzureRMSLicensingEnabled, InternalLicensingEnabled, SimplifiedClientAccessEnabled, LicensingLocation
