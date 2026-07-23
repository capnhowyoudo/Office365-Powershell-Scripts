<#
.SYNOPSIS
    Retrieves the RejectDirectSend setting for the Exchange Online organization.

.DESCRIPTION
    Queries the organization configuration using Get-OrganizationConfig and returns
    the tenant Identity along with the RejectDirectSend property, which indicates
    whether Direct Send (unauthenticated SMTP submission from internal domains,
    e.g. from printers/apps sending as your own domain without auth) is rejected.

.NOTES
    Author:     capnhowyoudo
    Date:       7/23/2026
    Requires:   Exchange Online PowerShell module (ExchangeOnlineManagement)
                and an active connection via Connect-ExchangeOnline.
#>

Get-OrganizationConfig | Select-Object Identity, RejectDirectSend
