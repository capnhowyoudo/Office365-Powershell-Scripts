<#
.SYNOPSIS
Shows all distribution groups that are hidden from the Global Address List (GAL).
#> 

Get-DistributionGroup | Where-Object { $_.HiddenFromAddressListsEnabled -eq $true } | Select-Object Name, HiddenFromAddressListsEnabled
