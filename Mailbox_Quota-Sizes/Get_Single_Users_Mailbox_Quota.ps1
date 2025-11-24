<#
.SYNOPSIS
Retrieves mailbox quota settings for a specified mailbox and displays them in a list format.

.DESCRIPTION
This cmdlet retrieves and displays the quota settings for a specified mailbox. It includes the following quota settings:
- IssueWarningQuota: The quota at which the mailbox will trigger a warning.
- ProhibitSendQuota: The quota at which the mailbox will be prevented from sending new messages.
- ProhibitSendReceiveQuota: The quota at which the mailbox will be prevented from sending or receiving messages.
- UseDatabaseQuotaDefaults: Indicates whether the mailbox is using the default database quotas.

.PARAMETER Identity
Specifies the email address or identity of the mailbox whose quota settings are being retrieved. The parameter should be in a valid email address format (e.g., user@example.com).

.NOTES
Example Usage:
    Get-Mailbox "user@example.com" | Format-List IssueWarningQuota, ProhibitSendQuota, ProhibitSendReceiveQuota, UseDatabaseQuotaDefaults
    This will retrieve the quota settings for "user@example.com" and display them in a list format.

This cmdlet helps administrators review and manage mailbox quotas for users in an Exchange environment.

#>

# Retrieve and display mailbox quota settings for the mailbox "user@example.com"

Get-Mailbox "user@example.com" | Format-List IssueWarningQuota, ProhibitSendQuota, ProhibitSendReceiveQuota, UseDatabaseQuotaDefaults
