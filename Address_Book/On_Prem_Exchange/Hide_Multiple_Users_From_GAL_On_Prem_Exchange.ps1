<#
.SYNOPSIS
Hides specified Active Directory users from On Prem Exchange Address Lists / GAL.

.DESCRIPTION
This script updates the Active Directory attribute
'msExchHideFromAddressLists' to TRUE for each user listed
in the $UsersToHide array.

This is commonly used in on-premises Exchange or hybrid
Exchange environments to hide mail-enabled users from the
Global Address List (GAL) and other Exchange address books.

Requirements:
- ActiveDirectory PowerShell module
- Appropriate AD permissions
- Exchange schema extensions present in Active Directory

Tested In:
- Windows Server 2016+
- Exchange On-Premises / Hybrid environments

Example:
.\Hide_Multiple_Users_From_GAL_On_Prem_Exchange.ps1
#>

# Hide selected users from Exchange Address Lists / GAL
# Using generic username examples

$UsersToHide = @(
    "user1",
    "user2",
    "user3",
    "user4",
    "user5"
)

foreach ($User in $UsersToHide) {

    try {

        Write-Host "Processing $User ..." -ForegroundColor Yellow

        Set-ADUser -Identity $User -Replace @{
            msExchHideFromAddressLists = $true
        }

        Write-Host "$User hidden successfully." -ForegroundColor Green

    }
    catch {

        Write-Host "FAILED: $User" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red

    }
}
