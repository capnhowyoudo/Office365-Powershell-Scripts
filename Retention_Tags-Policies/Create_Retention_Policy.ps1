<#
.SYNOPSIS
Creates a new Microsoft 365 Retention Policy and links it to multiple Retention Tags.

.DESCRIPTION
This cmdlet creates a new Retention Policy in Exchange Online and associates it with the
specified Retention Policy Tags. Retention Policies control how long mailbox items are kept,
when they are moved to an archive mailbox, and when they are deleted.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Permission Requirements:
    - Organization Management
    - Compliance Administrator (optional but recommended)

Retention Tag Details:
    - Never Delete: Items are retained indefinitely and never deleted automatically.
    - 3 Year Move to Archive: Items older than 3 years are moved to the archive mailbox.
    - 5 Year Delete: Items older than 5 years are permanently deleted.
    - 1 Year Delete: Items older than 1 year are permanently deleted.
    - 6 Month Delete: Items older than 6 months are permanently deleted.
    - 1 Month Delete: Items older than 1 month are permanently deleted.
    - 1 Week Delete: Items older than 1 week are permanently deleted.
    - Junk Email: Items in the Junk Email folder are deleted according to this tag.
    - Personal 5 year move to archive: User-specific items older than 5 years are moved to archive.
    - Personal never move to archive: User-specific items are never archived or deleted.
    - Personal 1 year move to archive: User-specific items older than 1 year are moved to archive.
    - Recoverable Items 14 days move to archive: Items in Recoverable Items are moved to archive after 14 days.

Additional Notes:
    - Retention policies may take up to 24 hours to fully apply across all mailboxes.
    - All retention tags must exist before linking them to a new policy.
    - Review and adjust tags based on organizational compliance requirements.
#>

New-RetentionPolicy "3 Years Moves to Archive" -RetentionPolicyTagLinks "Never Delete","3 Year Move to Archive","5 Year Delete","1 Year Delete","6 Month Delete","1 Month Delete","1 Week Delete","Junk Email","Personal 5 year move to archive","Personal never move to archive","Personal 1 year move to archive","Recoverable Items 14 days move to archive"

