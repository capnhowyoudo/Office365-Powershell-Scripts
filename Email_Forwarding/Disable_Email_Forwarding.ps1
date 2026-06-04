<#
.SYNOPSIS
Disables mailbox forwarding for a single user in Exchange.
.DESCRIPTION
This script uses the Set-Mailbox cmdlet to disable all email forwarding
on the specified mailbox and stop retaining forwarded copies.
.NOTES
Required PowerShell module:
- ExchangeOnlineManagement (for Exchange Online)
- Exchange Management Shell (for on-premises Exchange)
Parameters:
-ForwardingAddress : Set to $null to clear any configured forwarding address.
-ForwardingSmtpAddress : Set to $null to clear any SMTP forwarding address.
-DeliverToMailboxAndForward : Set to $false to disable forwarding entirely.
Compatibility:
- Works in both Exchange Online and on-premises Exchange environments.
#>

# Define the mailbox to disable forwarding on
$user = "user@domain.com"

Write-Host "Disabling forwarding for: $user" -ForegroundColor Cyan

try {
    Set-Mailbox -Identity $user -ForwardingAddress $null -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false -ErrorAction Stop
    Write-Host "Successfully disabled forwarding for $user" -ForegroundColor Green
}
catch {
    Write-Warning "Failed to disable forwarding for $user. Ensure the identity is correct."
}
