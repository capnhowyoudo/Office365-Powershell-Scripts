<#
.SYNOPSIS
Enables an auto-reply on a shared mailbox for a departed employee.

.DESCRIPTION
Sets an HTML auto-reply message on the specified Exchange Online mailbox using
Set-MailboxAutoReplyConfiguration. The same message is used for internal and
external senders (ExternalAudience is set to All). The message tells senders the
person is no longer with the company, that their email is being forwarded to a
team member, and gives contact details for quotes, purchase orders/order status,
and urgent matters.

Before running, replace "SharedMailboxName" with the actual mailbox identity and
update the placeholder email addresses and phone number in the message.

.NOTES
This is what the auto reply will look like when it is sent:

Thank you for your email.

The person you are trying to reach is no longer with our company. Your message is being forwarded to a team member and will be monitored for a short time before this mailbox is disabled.

For immediate assistance, please contact us directly:
Quote Requests: sales@yourcompany.com
Purchase Orders & Order Status Inquiries: orders@yourcompany.com
Phone: 000-000-0000

For urgent or critical matters, please call us to ensure a timely response.

Thank you for your understanding,
The Sales Team

Formatting notes:
* Each <p>...</p> block becomes its own paragraph with spacing above and below.
* <br> forces a new line within the same paragraph, which is why the three contact lines and the sign-off stay grouped together without blank lines between them.
* The "@ at the end of the message is not part of the message. It only closes the PowerShell here-string, so leave it out of the email text itself.
#>

$msg = @"
<p>Thank you for your email.</p>
<p>The person you are trying to reach is no longer with our company. Your message is being forwarded to a team member and will be monitored for a short time before this mailbox is disabled.</p>
<p>For immediate assistance, please contact us directly:<br>
Quote Requests: sales@yourcompany.com<br>
Purchase Orders &amp; Order Status Inquiries: orders@yourcompany.com<br>
Phone: 000-000-0000</p>
<p>For urgent or critical matters, please call us to ensure a timely response.</p>
<p>Thank you for your understanding,<br>
The Sales Team</p>
"@

Set-MailboxAutoReplyConfiguration -Identity "SharedMailboxName" `
  -AutoReplyState Enabled `
  -ExternalAudience All `
  -InternalMessage $msg `
  -ExternalMessage $msg
