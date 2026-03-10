<#
.SYNOPSIS
Retrieves calendar processing settings for a specific mailbox.

.DESCRIPTION
This command queries a mailbox to display its calendar processing configuration.
It shows whether the mailbox processes external meeting messages and how it
handles meeting request subjects and comments. This is useful for reviewing
resource mailbox settings and ensuring external meeting requests are processed
correctly.

.NOTES
Generic example for viewing calendar processing settings of a mailbox.
#>

# Retrieve calendar processing settings for a mailbox using a generic email
Get-CalendarProcessing -Identity "user@domain.com" | Select-Object Identity, ProcessExternalMeetingMessages, DeleteSubject, DeleteComments
