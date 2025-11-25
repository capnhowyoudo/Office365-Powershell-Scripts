<#
.SYNOPSIS
Retrieves all inbox rules for a specified mailbox.

.DESCRIPTION
This command uses the Get-InboxRule cmdlet to list all the inbox rules configured
for a mailbox in Exchange Online or Exchange on-premises. It provides details such as
rule name, priority, conditions, actions, and whether the rule is enabled.

.NOTES
Requires: Exchange Online PowerShell Module or Exchange Management Shell
Example Usage: 
    Get-InboxRule -Mailbox Joe@Contoso.com
#>

Get-InboxRule -Mailbox Joe@Contoso.com
