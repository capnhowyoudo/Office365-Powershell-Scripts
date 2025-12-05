<#
.SYNOPSIS
Configures automatic reply settings for a mailbox or a shared mailbox, enabling internal and external auto-reply messages.

.DESCRIPTION
This cmdlet enables automatic replies for the specified mailbox and applies the provided
internal and external messages. Internal messages are shown only to senders inside the
organization, while external messages are delivered to outside senders.

This cmdlet works in both **Exchange On-Premises (Exchange Management Shell)** and
**Exchange Online (Exchange Online PowerShell module)**. The syntax and parameters are
consistent in both environments.

.EXAMPLE
This example enables automatic replies for the "HRTeam" shared mailbox and sets custom
messages for internal and external users:

Set-MailboxAutoReplyConfiguration -Identity "HRTeam" -AutoReplyState Enabled `
 -InternalMessage "HR Team is currently unavailable. We will respond when we return." `
 -ExternalMessage "Thank you for contacting HR. Our team is away and will reply as soon as possible."

This example works in both **Exchange On-Prem** and **Exchange Online**.
#>

# Set mailbox auto-reply configuration
Set-MailboxAutoReplyConfiguration -Identity "SharedMailboxName" -AutoReplyState Enabled -InternalMessage "Your internal auto-reply message here." -ExternalMessage "Your external auto-reply message here."
