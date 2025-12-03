<#
.SYNOPSIS
Displays the retention policy assigned to a specific mailbox in Microsoft 365.

.DESCRIPTION
This cmdlet retrieves a mailbox and shows the RetentionPolicy currently applied. 
Retention Policies define how long items are retained, when they are moved to the archive, 
and when they are deleted. This command is useful for auditing or verifying mailbox retention settings.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - Replace the mailbox identity with your specific mailbox email or alias.
    - You must have appropriate Exchange Online administrative permissions to view mailbox properties.
#>

Get-Mailbox "user@example.com" | Select RetentionPolicy
