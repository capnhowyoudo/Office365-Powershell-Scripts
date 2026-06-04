<#
.SYNOPSIS
Checks mailbox forwarding settings for a single user in Exchange.

.DESCRIPTION
This script uses the Get-Mailbox cmdlet to retrieve and display the current
email forwarding configuration for a specified mailbox.
It will report:
- ForwardingAddress
- ForwardingSmtpAddress
- DeliverToMailboxAndForward

.NOTES
Author: capnhowyoudo
Version:       1.0

Required PowerShell module:
- ExchangeOnlineManagement (for Exchange Online)
- Exchange Management Shell (for on-premises Exchange)

Compatibility:
- Works in both Exchange Online and on-premises Exchange environments.
#>

# Define the mailbox to check
$user = "user@domain.com"

Write-Host "Checking forwarding settings for: $user" -ForegroundColor Cyan

try {
    $mailbox = Get-Mailbox -Identity $user -ErrorAction Stop

    Write-Host "`nForwarding Settings for $user" -ForegroundColor Yellow
    Write-Host "-----------------------------------"
    Write-Host "ForwardingAddress        : $($mailbox.ForwardingAddress)"
    Write-Host "ForwardingSmtpAddress    : $($mailbox.ForwardingSmtpAddress)"
    Write-Host "DeliverToMailboxAndForward: $($mailbox.DeliverToMailboxAndForward)"
    Write-Host "-----------------------------------"

    if ($mailbox.ForwardingAddress -or $mailbox.ForwardingSmtpAddress) {
        Write-Host "Forwarding is ENABLED for $user" -ForegroundColor Red
    }
    else {
        Write-Host "Forwarding is DISABLED for $user" -ForegroundColor Green
    }
}
catch {
    Write-Warning "Failed to retrieve mailbox for $user. Ensure the identity is correct."
}
