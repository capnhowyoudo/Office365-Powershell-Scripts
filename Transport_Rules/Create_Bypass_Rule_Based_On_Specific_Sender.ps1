<#
.SYNOPSIS
Creates a transport rule that bypasses Clutter for emails sent from a specific sender.

.DESCRIPTION
This script creates an Exchange Online transport rule that checks the sender address of  
incoming messages. If the email originates from the specified sender, the rule applies a  
header instructing Exchange Online to bypass Clutter filtering.  
This ensures important automated or system-generated messages are delivered directly  
to the inbox and are not diverted by Clutter.

.NOTES
Module Required:
    - Exchange Online PowerShell (EXO V2)
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - Bypasses Clutter by setting the header:
        "X-MS-Exchange-Organization-BypassClutter" = "true"
    - Helpful for automated notifications or payroll systems that must never be filtered.
    - Replace the sender address with your organization's required address.
    - View existing mail flow rules with: Get-TransportRule
#>

New-TransportRule -Name Paylocity_bypass_clutter -From "do-not-reply@example.com" -SetHeaderName "X-MS-Exchange-Organization-BypassClutter" -SetHeaderValue "true"
