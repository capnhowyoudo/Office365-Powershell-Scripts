<#
.SYNOPSIS
    Disables rejection of Direct Send for the Exchange Online organization.

.DESCRIPTION
    Sets the RejectDirectSend property on the organization configuration to $false,
    which stops Exchange Online from rejecting unauthenticated Direct Send SMTP
    submissions (e.g. from printers, scanners, or line-of-business apps sending
    "as" your own domain without authentication).

.NOTES
    Author:     cpanhowyoudo
    Date:       7/23/2026
    Requires:   Exchange Online PowerShell module (ExchangeOnlineManagement)
                and an active connection via Connect-ExchangeOnline.
    Impact:     Setting this to $false lowers the security posture around
                Direct Send. Confirm this change aligns with your organization's
                mail-flow and anti-spoofing requirements before applying.
#>

Set-OrganizationConfig -RejectDirectSend $false
