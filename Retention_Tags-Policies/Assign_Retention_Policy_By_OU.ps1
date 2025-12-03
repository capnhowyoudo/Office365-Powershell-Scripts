<#
.SYNOPSIS
Applies a retention policy to all mailboxes in a specific organizational unit (OU) in Microsoft 365.

.DESCRIPTION
This cmdlet sets a specific Retention Policy for all mailboxes within a specified OU. 
Retention Policies define how long items are retained, when they are moved to the archive, 
and when they are deleted. Applying a retention policy to a subset of mailboxes allows targeted 
compliance management based on department or business unit.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - The retention policy specified must already exist in your environment.
    - Replace the OrganizationalUnit and RetentionPolicy names with your environment-specific values.
    - Example placeholders: OU = "Finance-Department", RetentionPolicy = "Corporate-RetentionPolicy".
    - Appropriate Exchange Online administrative permissions are required to apply policies to mailboxes.
#>

Get-Mailbox -OrganizationalUnit "Finance-Department" -ResultSize Unlimited | Set-Mailbox -RetentionPolicy "Corporate-RetentionPolicy"
