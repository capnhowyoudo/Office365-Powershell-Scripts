<#
.SYNOPSIS
Retrieves the list of trusted senders and domains for a specified mailbox's Junk Email configuration.

.DESCRIPTION
This cmdlet retrieves the list of trusted senders and domains from the Junk Email configuration for a specified mailbox. This is useful for managing trusted sources and ensuring that legitimate emails from certain senders or domains are not marked as junk.

.PARAMETER Identity
Specifies the email address of the mailbox whose Junk Email configuration settings are being retrieved. This parameter should be provided in a valid email address format (e.g., user@example.com).

.NOTES
Example Usage:
    (Get-MailboxJunkEmailConfiguration -Identity user@example.com).trustedSendersAndDomains
    (Get-MailboxJunkEmailConfiguration -Identity john.doe@company.com).trustedSendersAndDomains

This cmdlet is helpful for checking and reviewing the trusted senders and domains configured in a mailbox's Junk Email settings, ensuring that important messages are not mistakenly filtered into the Junk folder.

#>

(Get-MailboxJunkEmailConfiguration -Identity user@example.com).trustedSendersAndDomains
