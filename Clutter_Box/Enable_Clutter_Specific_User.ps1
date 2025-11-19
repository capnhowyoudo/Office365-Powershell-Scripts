<#
.SYNOPSIS
Disables the Clutter feature for a specific mailbox in Exchange Online.

.DESCRIPTION
The Set-Clutter cmdlet is used to enable or disable the legacy Clutter feature for a mailbox.
Clutter automatically moves low-priority messages to a separate folder, although Microsoft has
now replaced this behavior with the Focused Inbox experience.

This example disables Clutter for a mailbox using a generic email address.

.NOTES
• Requires the Exchange Online PowerShell module.  
• Clutter is deprecated but still manageable in some environments.  
• No error is thrown if Clutter is already disabled.  
• Syntax:  
    Set-Clutter -Identity <UserPrincipalName> -Enable <$true | $false>
#>

Set-Clutter -Identity user@example.com -Enable $true
