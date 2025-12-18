<#
.SYNOPSIS
Creates a mail contact and sets mailbox forwarding to the contact.

.DESCRIPTION
This script performs two actions:
1. Creates a mail contact for an external email address.
2. Configures a mailbox to forward all incoming emails to the newly created contact
   while keeping a copy in the original mailbox.

.NOTES
Required PowerShell module:
- ExchangeOnlineManagement (for Exchange Online)
- Exchange Management Shell (for on-premises Exchange)

Steps:
1. New-MailContact - Creates a mail-enabled contact for external recipients.
2. Set-Mailbox - Sets forwarding from the source mailbox to the mail contact.

Parameters:
-New-MailContact:
  -Name : Display name of the contact.
  -ExternalEmailAddress : The external email address to receive forwarded emails.

-Set-Mailbox:
  -ForwardingAddress : Set to the mail contact to forward emails.
  -DeliverToMailboxAndForward : $true keeps a copy in the original mailbox.

Compatibility:
- Works in both Exchange Online and on-premises Exchange environments.

Additional notes:
- To forward without keeping copies in the original mailbox, set -DeliverToMailboxAndForward $false.
#>

# Step 1: Create a mail contact for external forwarding
New-MailContact -Name "ExternalForward" -ExternalEmailAddress "user@externaldomain.com"

# Step 2: Forward emails from SourceMailbox to the external contact and keep a copy
Set-Mailbox "SourceMailbox" -ForwardingAddress "ExternalForward" -DeliverToMailboxAndForward $true
