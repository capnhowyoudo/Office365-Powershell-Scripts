<#
.SYNOPSIS
    Checks whether SMTP AUTH (client authentication) is disabled for a specific mailbox in Exchange Online.

.DESCRIPTION
    This script connects to Exchange Online via the ExchangeOnlineManagement module,
    then retrieves the CAS (Client Access Services) mailbox settings for a specified
    user to check the current status of the SmtpClientAuthenticationDisabled property.
    This is useful for auditing whether basic SMTP authentication is allowed or blocked
    on a per-mailbox basis, which is relevant to security hardening efforts (e.g., 
    preventing legacy auth-based attacks).
#>

Connect-ExchangeOnline

# Check current status first
Get-CASMailbox -Identity user@contoso.com | Select-Object SmtpClientAuthenticationDisabled
