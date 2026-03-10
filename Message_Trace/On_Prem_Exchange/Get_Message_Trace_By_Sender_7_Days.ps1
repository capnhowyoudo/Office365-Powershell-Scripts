<#
.SYNOPSIS
Retrieves message tracking log entries for a specific sender over the past 7 days.

.DESCRIPTION
This command queries the Exchange message tracking logs for messages sent from
the specified sender within the last 7 days. It returns details including the
timestamp, event ID, source, message subject, all recipients, and recipient
status. The results are sorted by timestamp in descending order and displayed
in an interactive Out-GridView window for easier analysis and filtering.

.NOTES
Generic example for reviewing sent message activity from a specific sender.
#>

# Retrieve message tracking logs for the specified sender over the last 7 days and display results in a grid view
Get-MessageTrackingLog -Sender "sender@senderdomain.com" -Start (Get-Date).AddDays(-7) | Select-Object Timestamp, EventId, Source, MessageSubject, @{Name="All_Recipients";Expression={$_.Recipients}}, RecipientStatus | Sort-Object Timestamp -Descending | Out-GridView
