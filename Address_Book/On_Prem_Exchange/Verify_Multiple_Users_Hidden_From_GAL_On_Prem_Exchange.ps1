<#
.SYNOPSIS
Verifies that specified Active Directory users are hidden from
Exchange Address Lists / GAL and exports the results to a text file.

.DESCRIPTION
This script checks the Active Directory attribute
'msExchHideFromAddressLists' for each user listed in the
$UsersToHide array.

The script outputs verification results to the console and
exports the results to:

C:\Temp\GAL_Hide_Verification.txt

This script is intended ONLY for On-Premises Exchange
environments where Exchange attributes are managed directly
through Active Directory.

Requirements:
- ActiveDirectory PowerShell module
- Appropriate AD permissions
- Exchange schema extensions present in Active Directory

Supported Environments:
- Exchange Server On-Premises
- Exchange Hybrid (when attributes are managed on-prem)

Not Intended For:
- Exchange Online only environments
- Cloud-only Microsoft 365 tenants without on-prem AD

Output File:
C:\Temp\GAL_Hide_Verification.txt

Example:
.\Verify-GALHide.ps1
#>

# Verification Script
# Confirms users are hidden from Exchange Address Lists / GAL

$UsersToHide = @(
    "user1",
    "user2",
    "user3",
    "user4",
    "user5"
)

# Create output folder if it doesn't exist
if (!(Test-Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" | Out-Null
}

$OutputFile = "C:\Temp\GAL_Hide_Verification.txt"

# Clear old report if it exists
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile
}

foreach ($User in $UsersToHide) {

    try {

        $ADUser = Get-ADUser -Identity $User -Properties msExchHideFromAddressLists

        $Status = if ($ADUser.msExchHideFromAddressLists -eq $true) {
            "HIDDEN SUCCESSFULLY"
        }
        else {
            "NOT HIDDEN"
        }

        $Result = @"
===================================
Name: $($ADUser.Name)
Username: $($ADUser.SamAccountName)
Hidden From Address Lists: $($ADUser.msExchHideFromAddressLists)
STATUS: $Status

"@

        Write-Host $Result

        Add-Content -Path $OutputFile -Value $Result

    }
    catch {

        $ErrorResult = @"
===================================
FAILED TO VERIFY: $User
ERROR: $($_.Exception.Message)

"@

        Write-Host $ErrorResult -ForegroundColor Red

        Add-Content -Path $OutputFile -Value $ErrorResult

    }
}

Write-Host "Verification report exported to $OutputFile" -ForegroundColor Green
