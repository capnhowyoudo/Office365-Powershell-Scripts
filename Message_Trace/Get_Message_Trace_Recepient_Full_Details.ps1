<#
.SYNOPSIS
    Retrieves message trace logs for a specific recipient and displays full details in a list format.

.DESCRIPTION
    This command queries Exchange Online for message trace data for a specific recipient.
    The output is piped to 'fl' (Format-List), which expands the output to show all properties of the message trace object in a readable, vertical list.
    This is useful for viewing properties that get truncated in the default table view, such as MessageTraceId or detailed status information.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module.
    - Context: Exchange Online / Office 365 environment.
    - 'fl' is an alias for the 'Format-List' cmdlet.

    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Open PowerShell and authenticate to your tenant:
       Connect-ExchangeOnline

    2. Copy and paste the command below, replacing 'user@domain.com' with the target email address.

    3. Press Enter to view the detailed trace logs in the console window.
#>

Get-MessageTrace -RecipientAddress user@domain.com | fl
