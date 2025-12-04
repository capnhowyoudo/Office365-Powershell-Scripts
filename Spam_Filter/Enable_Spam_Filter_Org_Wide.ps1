<#
.SYNOPSIS
Enables Junk Email Configuration for all mailboxes in the organization.

.DESCRIPTION
This command retrieves all mailboxes and enables the Junk Email Configuration feature.
When enabled, Outlook and Exchange Online apply junk mail filtering rules for each mailbox.
This is useful for ensuring organization-wide junk email protection is active.

.NOTES
Module Required:
    - Exchange Online PowerShell (EXO V2)
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - Administrative permissions are required to modify mailbox junk email settings.
    - This change applies to every mailbox returned by Get-Mailbox.
    - Use Get-MailboxJunkEmailConfiguration to verify settings if needed.
#>

Get-Mailbox | Set-MailboxJunkEmailConfiguration -Enabled $true
