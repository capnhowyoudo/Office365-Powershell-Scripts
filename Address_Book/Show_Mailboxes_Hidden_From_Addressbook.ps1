<#
.SYNOPSIS
Shows all mailboxes that are hidden from the Global Address List (GAL).
#> 

Get-Mailbox -ResultSize Unlimited | Where-Object {$_.HiddenFromAddressListsEnabled -eq $true} | Select-Object DisplayName, PrimarySmtpAddress
