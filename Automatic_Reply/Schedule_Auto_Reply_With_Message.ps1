<#
.SYNOPSIS
Configures scheduled automatic replies for a mailbox.

.DESCRIPTION
This cmdlet enables automatic replies for a specified date range using the Scheduled
AutoReplyState. Internal and external messages will only be sent between the defined
StartTime and EndTime.

This cmdlet works in both **Exchange On-Premises (Exchange Management Shell)** and
**Exchange Online (Exchange Online PowerShell module)** with identical syntax.

.EXAMPLE
This example enables scheduled automatic replies for the "HRTeam" shared mailbox from
December 5th to December 12th:

Set-MailboxAutoReplyConfiguration -Identity "HRTeam" `
    -AutoReplyState Scheduled `
    -StartTime "2025-12-05 08:00" `
    -EndTime "2025-12-12 17:00" `
    -InternalMessage "HR Team is currently unavailable." `
    -ExternalMessage "Thank you for contacting HR. The team will respond when they return."

This example works in both **Exchange On-Prem** and **Exchange Online**.
#>

# Set scheduled mailbox auto-reply configuration
Set-MailboxAutoReplyConfiguration -Identity "SharedMailboxName" `
    -AutoReplyState Scheduled `
    -StartTime "2025-12-05 08:00" `
    -EndTime "2025-12-12 17:00" `
    -InternalMessage "Internal auto-reply." `
    -ExternalMessage "External auto-reply."
