<#
.SYNOPSIS
Applies a retention policy to all mailboxes in Microsoft 365.

.DESCRIPTION
This cmdlet sets a specific Retention Policy for all mailboxes retrieved in the organization. 
Retention Policies define how long items are retained, when they are moved to the archive, 
and when they are deleted. Applying a retention policy to all mailboxes ensures consistent 
compliance with organizational data retention requirements.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - The retention policy specified must already exist in your environment.
    - Appropriate Exchange Online administrative permissions are required to apply policies to mailboxes.
    - Replace the retention policy name with the one that matches your compliance requirements.
#>

Get-Mailbox -ResultSize Unlimited | Set-Mailbox -RetentionPolicy "RetentionPolicy-Default"
