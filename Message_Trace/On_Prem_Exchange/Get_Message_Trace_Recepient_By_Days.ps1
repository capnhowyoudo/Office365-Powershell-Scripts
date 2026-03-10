<#
.SYNOPSIS
Retrieves message tracking log entries for a specific recipient over the past day.

.DESCRIPTION
This command queries the Exchange message tracking logs for messages sent to the
specified recipient within the last 24 hours. It returns selected properties such
as the timestamp, sender, event ID, source, and message subject. The results are
then displayed in an interactive Out-GridView window for easier filtering and review.

.NOTES
Generic example for Exchange message tracking review.
#>

# Retrieve message tracking logs for the specified recipient in the last 24 hours and display results in a grid view
Get-MessageTrackingLog -Recipient "pf-email@yourdomain.com" -Start (Get-Date).AddDays(-1) | Select-Object Timestamp, Sender, EventId, Source, MessageSubject | Out-GridView
