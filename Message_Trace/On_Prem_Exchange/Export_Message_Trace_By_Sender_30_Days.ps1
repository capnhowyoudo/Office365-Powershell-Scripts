<#
.SYNOPSIS
Retrieves message tracking log entries for a specific sender over the past 30 days and exports the results to a CSV file.

.DESCRIPTION
This command queries the Exchange message tracking logs for messages sent from
the specified sender within the last 30 days. It collects information such as
timestamp, event ID, source, message subject, recipients, recipient status, and
database context. The results are exported to a CSV file for reporting, auditing,
or further analysis outside of PowerShell.

.NOTES
Generic example for exporting Exchange message tracking history to CSV.
#>

# Retrieve message tracking logs for the specified sender over the last 30 days and export results to CSV
Get-MessageTrackingLog -Sender "sender@senderdomain.com" -Start (Get-Date).AddDays(-30) | Select-Object Timestamp, EventId, Source, MessageSubject, Recipients, RecipientStatus, @{Name="Database";Expression={$_.SourceContext}} | Export-Csv -Path "C:\Temp\TopSpot_Full_History.csv" -NoTypeInformation
