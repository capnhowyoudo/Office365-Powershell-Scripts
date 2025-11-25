<#
.SYNOPSIS
    Retrieves message trace logs for a specific sender and outputs to a grid view.

.DESCRIPTION
    This command queries Exchange Online for message trace data regarding emails sent by a specific address within a defined date range.
    It selects specific properties including time received, recipient address, subject, source IP, and delivery status.
    The results are displayed in an interactive GridView window.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module.
    - Context: Exchange Online / Office 365 environment.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Open PowerShell and authenticate to your tenant:
       Connect-ExchangeOnline
       
    2. Copy and paste the command below. Change 'user@domain.com' to the sender you are investigating.
    
    3. Adjust the -StartDate and -EndDate to your required search window (Format: MM/DD/YY).
#>

Get-MessageTrace -senderAddress user@domain.com -StartDate 09/24/24 -EndDate 10/5/24 | Select-Object received, senderaddress, recipientaddress, subject, fromip, size, messagetraceid, status | Out-GridView
