<#
.SYNOPSIS
    Retrieves all inbox rules for a mailbox, including hidden system rules.

.DESCRIPTION
    This script fetches both visible and hidden inbox rules. Hidden rules are often 
    created by the system for features like Out of Office, Clutter, or junk email 
    filtering, but they can also be used by malicious actors to hide forwarding rules.

.NOTES
    Compatibility: Works with both Exchange Online and Exchange On-Premises.
    Warning: Hidden rules should be modified with caution as they are often system-managed.
#>
Get-InboxRule -Mailbox "user@domain.com" -IncludeHidden
