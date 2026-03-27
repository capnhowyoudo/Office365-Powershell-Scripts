<#
.SYNOPSIS
    Displays Exchange message tracking logs from the last 24 hours in a GUI.

.DESCRIPTION
    Retrieves Timestamp, Sender, Recipients, EventID, Source, and Subject 
    for all messages logged in the past day and pipes them to Out-GridView.

.NOTES
    Run this from the Exchange Management Shell.
#>

Get-MessageTrackingLog -Start (Get-Date).AddDays(-1) -ResultSize Unlimited | Select-Object Timestamp,Sender,Recipients,EventId,Source,MessageSubject | Out-GridView
