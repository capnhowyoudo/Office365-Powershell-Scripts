<#
.SYNOPSIS
    Identifies email forwarding and redirection rules for a specific mailbox.

.DESCRIPTION
    This script retrieves all inbox rules and filters them to display only those 
    that forward or redirect messages to another address. This is a common 
    security audit practice to detect unauthorized data exfiltration.

.NOTES
    Compatibility: This script works with both Exchange Online and Exchange On-Premises.
    Prerequisites: Ensure you are connected to the appropriate Exchange environment.
#>
Get-InboxRule -Mailbox "user@domain.com" | Where-Object { $_.ForwardTo -ne $null -or $_.RedirectTo -ne $null } | Select-Object Name, ForwardTo, RedirectTo
