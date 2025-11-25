<#
.SYNOPSIS
    Retrieves message trace logs for a specific recipient and outputs to a grid view.

.DESCRIPTION
    This command queries Exchange Online for message trace data regarding a specific recipient email address within a defined date range.
    It selects specific properties including time received, sender address, subject, source IP, and status.
    The final output is piped to an interactive GridView window for sorting and filtering.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module.
    - Context: Exchange Online / Office 365 environment.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Open PowerShell and authenticate to your tenant:
       Connect-ExchangeOnline
       
    2. copy and paste the command below, adjusting the -StartDate and -EndDate to your required search window (Format: MM/DD/YY).
    
    3. Press Enter. A grid window will pop up allowing you to search and filter the results.
#>

Get-MessageTrace -RecipientAddress user@domain.com -StartDate 09/24/24 -EndDate 10/5/24 | Select-Object received, senderaddress, recipientaddress, subject, fromip, size, messagetraceid, status | Out-GridView
