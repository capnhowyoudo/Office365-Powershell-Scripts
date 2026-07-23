<#
.SYNOPSIS
    Enables rejection of Direct Send for the Exchange Online organization.

.DESCRIPTION
    Sets the RejectDirectSend property on the organization configuration to $true,
    which causes Exchange Online to reject unauthenticated Direct Send SMTP
    submissions (e.g. spoofed messages claiming to be from your own accepted
    domains without proper authentication). This is the more secure setting and
    helps reduce internal-domain spoofing/phishing risk.

.NOTES
    Author:     capnhowyoudo
    Date:       7/23/2026
    Requires:   Exchange Online PowerShell module (ExchangeOnlineManagement)
                and an active connection via Connect-ExchangeOnline.
    Impact:     Legitimate devices/apps that rely on unauthenticated Direct Send
                (printers, scanners, line-of-business apps) may stop being able
                to send mail. Confirm those senders use authenticated SMTP,
                a connector, or are otherwise accounted for before enabling this.
#>

Set-OrganizationConfig -RejectDirectSend $true
