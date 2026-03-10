<#
.SYNOPSIS
Configures a mailbox to process meeting requests from external senders.

.DESCRIPTION
This command updates the calendar processing settings for a specified mailbox,
allowing it to automatically process meeting requests sent from external users.
The `-ProcessExternalMeetingMessages $true` parameter ensures that meeting invites
from outside the organization are handled according to the mailbox’s resource
calendar processing rules.

.NOTES
To find all room mailbox email addresses, you can use:
Get-Mailbox -Filter '(RecipientTypeDetails -eq "RoomMailbox")' -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress
#>

# Enable processing of external meeting requests for a mailbox using a generic email
Set-CalendarProcessing -Identity "user@domain.com" -ProcessExternalMeetingMessages $true
