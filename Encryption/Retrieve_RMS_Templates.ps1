<#
.SYNOPSIS
    Retrieves and lists the available Rights Management Services (RMS) templates from the tenant.

.DESCRIPTION
    This command connects to the RMS engine to pull a list of active protection templates. 
    It displays the Name and unique Guid for each template. This is used to verify that 
    the templates have successfully synchronized to Exchange Online and are available 
    for use in Transport Rules or by end-users in Outlook.

.NOTES
    - PREREQUISITE: You must be connected to the Exchange Online module 
      using 'Connect-ExchangeOnline' before running this command.
    - TROUBLESHOOTING: If this returns nothing, it indicates that the 
      'LicensingLocation' sync in your primary setup script has not yet 
      propagated or failed.
    - USAGE: The 'Guid' found here can be used in advanced transport rules 
      to target specific custom protection labels.
    - AUTHOR: Adapted for VisualFusion Environment.
#>

# Ensure you are connected before running
# Connect-ExchangeOnline

# Retrieve and display the templates
Get-RMSTemplate | Select-Object Name, Guid
