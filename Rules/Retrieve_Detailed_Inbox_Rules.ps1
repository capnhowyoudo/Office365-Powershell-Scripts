<#
.SYNOPSIS
    Retrieves specific inbox rule details from a mailbox.

.DESCRIPTION
    This script retrieves the properties of a specified inbox rule. It is designed to 
    provide a comprehensive view of rule actions, conditions, and exceptions by 
    piping the output to Format-List.

.NOTES
    Compatibility: Works with both Exchange Online and Exchange On-Premises.
    Permissions: Requires View-Only Configuration or Mailbox Options roles.
#>
Get-InboxRule -Mailbox "user@domain.com" -Identity "Rule Name" | Format-List
