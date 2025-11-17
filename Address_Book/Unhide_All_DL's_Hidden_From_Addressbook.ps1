<#
.SYNOPSIS
Unhides all distribution groups so they are visible in the Global Address List (GAL).
#>

Get-DistributionGroup -ResultSize Unlimited | Set-DistributionGroup -HiddenFromAddressListsEnabled $false
