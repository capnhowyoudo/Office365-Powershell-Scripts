<#
.SYNOPSIS
    Enables SMTP AUTH (client authentication) organization-wide in Exchange Online.

.DESCRIPTION
    This script connects to Exchange Online via the ExchangeOnlineManagement module,
    then sets the tenant-wide transport configuration property
    SmtpClientAuthenticationDisabled to $false, allowing SMTP basic authentication
    by default across the entire organization. Individual mailbox settings (via
    Set-CASMailbox) can still override this default on a per-user basis. Enabling
    this tenant-wide should be done cautiously, since basic authentication lacks
    MFA support and is a common target for legacy auth-based attacks.
#>

Connect-ExchangeOnline

# Enable SMTP AUTH organization-wide
Set-TransportConfig -SmtpClientAuthenticationDisabled $false
