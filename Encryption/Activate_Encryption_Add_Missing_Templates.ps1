<#
.SYNOPSIS
    Resolves missing RMS templates and activates all backend prerequisites required for 
    manual email encryption to function within an Exchange Online tenant.

.DESCRIPTION
    This script automates the transition from legacy AD RMS cmdlets to the modern AIPService module. 
    It installs the necessary modules, connects to both Exchange Online and the AIP Service, 
    activates the service, and synchronizes the Licensing Location URLs. This ensures that 
    the "Protect" button in Outlook/OWA is functional and templates are available to users.

.NOTES
    - Prerequisites: You must have Global Admin or Exchange Admin privileges.
    - Replaces: Legacy 'Import-RMSTrustedPublishingDomain' (not needed for Azure RMS).
    - Author: Adapted for VisualFusion Environment.
    - Required Modules: 
        1. AIPService (replaces AADRM)
        2. ExchangeOnlineManagement (V3)

    LICENSING REQUIREMENTS:
    To use IRM/Encryption, the SENDER must have one of the following:
    1. Microsoft 365 E3 or E5
    2. Office 365 E3 or E5
    3. Microsoft 365 Business Premium
    4. Standalone Add-on: 'Azure Information Protection Plan 1' (for lower-tier plans).
    
    *Note: Recipients do not need a license to read or reply to encrypted mail.*

    Be sure to change email in step 8
#>

# 1. Install and prepare the environment
Install-Module -Name AIPService -Force -AllowClobber
Set-ExecutionPolicy Unrestricted -Scope Process

# 2. Establish connections
Connect-ExchangeOnline
Connect-AIPService

# 3. Activate the service (The "Engine")
Enable-AIPService

# 4. Sync Licensing Endpoints (The "Map")
$rmsConfig = Get-AipServiceConfiguration
$licenseUri = $rmsConfig.LicensingIntranetDistributionPointUrl

$irmConfig = Get-IRMConfiguration
$list = $irmConfig.LicensingLocation

if (!$list) { 
    $list = @() 
}

if (!$list.Contains($licenseUri)) { 
    $list += $licenseUri 
}

# 5. Enable message protection for Office 365
Set-IRMConfiguration -LicensingLocation $list
Set-IRMConfiguration -AzureRMSLicensingEnabled $True -InternalLicensingEnabled $true

# 6. Enable the "Protect" button in Outlook on the Web (The "User Interface")
Set-IRMConfiguration -SimplifiedClientAccessEnabled $true

# 7. Ensure External Recipients can use One-Time Passcodes (The "Compatibility")
Set-OMEConfiguration -Identity "OME Configuration" -OTPEnabled $true

# 8. Verify the configuration
# This checks if the sender can successfully acquire a license template.
Test-IRMConfiguration -Sender youremail@domain.com
