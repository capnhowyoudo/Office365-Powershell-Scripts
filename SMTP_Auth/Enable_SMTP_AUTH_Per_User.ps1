<#
.SYNOPSIS
    Enables SMTP AUTH (client authentication) for a specific mailbox in Exchange Online.

.DESCRIPTION
    This script connects to Exchange Online via the ExchangeOnlineManagement module,
    then sets the SmtpClientAuthenticationDisabled property to $false for a
    specified mailbox, allowing SMTP basic authentication for that user. This is
    typically done to support legacy applications, scanners/printers, or scripts
    that require SMTP AUTH to send mail, after weighing the security trade-offs of
    enabling basic authentication (which lacks MFA support).
#>

Connect-ExchangeOnline

# Enable SMTP AUTH for this mailbox
Set-CASMailbox -Identity user@contoso.com -SmtpClientAuthenticationDisabled $false
