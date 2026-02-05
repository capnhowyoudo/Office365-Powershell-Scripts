<#
.SYNOPSIS
    Appends a new recipient to an existing redirection inbox rule.

.DESCRIPTION
    This script retrieves the current 'RedirectTo' array from a specific rule 
    and adds a new recipient. Unlike 'ForwardTo', redirection keeps the 
    original sender's information intact for the final recipient.

.NOTES
    Compatibility: Works with both Exchange Online and Exchange On-Premises.
    Constraint: Ensure the "Rule Name" exists before running to avoid errors.
#>
Set-InboxRule -Mailbox "Owner@domain.com" -Identity "Rule Name" -RedirectTo ((Get-InboxRule -Mailbox "Owner@domain.com" -Identity "Rule Name").RedirectTo + "recipient@domain.com")
