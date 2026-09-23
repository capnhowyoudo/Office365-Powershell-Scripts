<#
.SYNOPSIS
    Checks the organization-wide SMTP AUTH (client authentication) setting in Exchange Online.

.DESCRIPTION
    This script connects to Exchange Online via the ExchangeOnlineManagement module,
    then retrieves the tenant-wide transport configuration to check the current status
    of the SmtpClientAuthenticationDisabled property. This setting acts as the default
    for the entire organization — individual mailbox settings (via Get-CASMailbox)
    can override it, but this shows the baseline tenant policy.
#>

Connect-ExchangeOnline

# Check organization-wide SMTP AUTH setting
Get-TransportConfig | Select-Object SmtpClientAuthenticationDisabled
