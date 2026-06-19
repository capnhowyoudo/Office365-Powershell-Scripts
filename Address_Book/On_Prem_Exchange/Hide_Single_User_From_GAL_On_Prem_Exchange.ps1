<#
.SYNOPSIS
    Hides a specified Active Directory user from the Global Address List (GAL).

.DESCRIPTION
    Sets the msExchHideFromAddressLists attribute to $true on a target AD user
    account, effectively hiding them from Exchange/Outlook address books and
    the Global Address List. Requires the ActiveDirectory module and sufficient
    permissions to modify AD user attributes.

.NOTES
    Author      :  capnhowyoudo
    Version     :  1.0
    Date        :  2026-06-19
    Requires    :  ActiveDirectory module, Exchange schema attributes
    Permissions :  Write access to msExchHideFromAddressLists on target user
#>

# ------------------------------------------------------- 
# Set the username of the user to hide from the GAL
# ------------------------------------------------------- 

$UserToHide = "user1"

# ------------------------------------------------------- 
try {
    Write-Host "Processing $UserToHide ..." -ForegroundColor Yellow
    Set-ADUser -Identity $UserToHide -Replace @{ msExchHideFromAddressLists = $true }
    Write-Host "$UserToHide hidden successfully." -ForegroundColor Green
} catch {
    Write-Host "FAILED: $UserToHide" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
