<#
.SYNOPSIS
Creates a transport rule that bypasses Clutter based on a specific word found in the email’s subject line.

.DESCRIPTION
This rule evaluates the subject line of incoming emails for the keyword “Voicemail.”  
If the keyword is detected, the rule applies a custom header instructing Exchange Online  
to bypass Clutter processing. This ensures that voicemail messages are delivered  
directly to the inbox without being filtered.

.NOTES
Module Required:
    - Exchange Online PowerShell (EXO V2)
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - Requires appropriate permissions to manage transport rules.
    - Uses the header: "X-MS-Exchange-Organization-BypassClutter" set to "true".
    - While Clutter is deprecated in many tenants, this header still functions where Clutter remains active.
#>

New-TransportRule -Name Voicemail_bypass_clutter -SubjectContainsWords "Voicemail" -SetHeaderName "X-MS-Exchange-Organization-BypassClutter" -SetHeaderValue "true"
