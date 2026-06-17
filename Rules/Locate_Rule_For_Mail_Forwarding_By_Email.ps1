<#
.SYNOPSIS
    Searches Exchange transport rules for any that forward, redirect, or copy messages to a specified email address.

.DESCRIPTION
    This script queries all Exchange Online transport rules and filters for any that reference
    a target email address in the following actions: RedirectMessageTo, BlindCopyTo, CopyTo,
    ForwardTo, or ForwardAsAttachmentTo. Useful for investigating unexpected mail forwarding
    identified in message trace results.

.NOTES
    Author      : capnhowyoudo
    Created     : 06/17/2025
    Version     : 1.0
    Requirements: Exchange Online PowerShell module (ExchangeOnlineManagement)
                  Must be connected via Connect-ExchangeOnline before running
    Usage       : Update $forwardAddress with the suspected destination address, then run the script.
                  If no results are returned, check mailbox-level forwarding and inbox rules.
#>

$forwardAddress = "user@domain.com"

Get-TransportRule | Where-Object {
    $_.RedirectMessageTo -match $forwardAddress -or
    $_.BlindCopyTo -match $forwardAddress -or
    $_.CopyTo -match $forwardAddress -or
    $_.ForwardTo -match $forwardAddress -or
    $_.ForwardAsAttachmentTo -match $forwardAddress
} | Format-List Name,State,Priority,RedirectMessageTo,BlindCopyTo,CopyTo,ForwardTo,ForwardAsAttachmentTo,Description
