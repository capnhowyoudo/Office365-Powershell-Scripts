<#
.SYNOPSIS
    Retrieves detailed event information for a specific message using its Trace ID.

.DESCRIPTION
    This command queries Exchange Online for the granular details of a specific message transaction.
    Unlike 'Get-MessageTrace' which gives a summary, 'Get-MessageTraceDetail' returns the sequence of events (e.g., Receive, Send, Fail, Spam Analysis) associated with that message.
    The output is formatted as a list to display all event details clearly.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module.
    - Context: Troubleshooting specific delivery failures or latency issues.
    - Prerequisite: You usually need to run 'Get-MessageTrace' first to obtain the 'MessageTraceId'.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Run a basic trace to find your message:
       $message = Get-MessageTrace -RecipientAddress user@domain.com -StartDate 09/24/24 -EndDate 09/25/24
       
    2. Use the ID from that message to get details:
       Get-MessageTraceDetail -MessageTraceId $message.MessageTraceId -RecipientAddress user@domain.com | fl
#>

Get-MessageTraceDetail -MessageTraceId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -RecipientAddress user@domain.com | fl
