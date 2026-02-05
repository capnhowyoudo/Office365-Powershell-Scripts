<#
.SYNOPSIS
    Appends a new recipient to an existing forwarding inbox rule.

.DESCRIPTION
    This script retrieves the current 'ForwardTo' list of a specific inbox rule 
    and adds a new email address to it. This prevents the existing recipients 
    from being overwritten, which is the default behavior of Set-InboxRule.

.NOTES
    Compatibility: Works with both Exchange Online and Exchange On-Premises.
    Pre-requisite: The rule specified by -Identity must already exist.
#>
Set-InboxRule -Mailbox "Owner@domain.com" -Identity "Rule Name" -ForwardTo ((Get-InboxRule -Mailbox "Owner@domain.com" -Identity "Rule Name").ForwardTo + "recipient@domain.com")
