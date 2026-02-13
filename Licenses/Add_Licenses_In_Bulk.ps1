<#
.SYNOPSIS
Adds a specific Microsoft 365 SKU license to a list of users.

.DESCRIPTION
Reads a list of user IDs from a text file, retrieves the SKU ID for the specified license
(O365_BUSINESS_ESSENTIALS), and iterates through the list to assign that license to each user.
RemoveLicenses is currently empty.

.NOTES
Requires Microsoft Graph PowerShell module (Mg) and appropriate permissions.
Ensure Connect-MgGraph is run before executing this script.

To change the license being assigned, update the SkuPartNumber value in the following line:
$sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq 'O365_BUSINESS_ESSENTIALS'

You can view available SKU part numbers by running:
Get-MgSubscribedSku | Select SkuPartNumber

The accounts file should contain one user principal name (UPN) or user ID per line, for example:
user1@example.com
user2@example.com
user3@example.com

Optional Connect to MS Graph Private Window (Some cmdlets may not work, known bug when using  -UseDeviceCode)
Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All -UseDeviceCode (note if you use a private window you may get the following error Get-MgSubscribedSku : DeviceCodeCredential authentication failed: Object reference not set to an instance of an object) If so do not use -UseDeviceCode
#>

Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All

$users = Get-Content "C:\Temp\Accounts.txt"
$sku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq 'O365_BUSINESS_ESSENTIALS'
$results = @()

foreach ($user in $users) {
    try {
        Write-Host "Processing: $user" -ForegroundColor Cyan
        
        # Adding the license
        Set-MgUserLicense -UserId $user -AddLicenses @(@{SkuId = $sku.SkuId}) -RemoveLicenses @()
        
        $results += [PSCustomObject]@{ User = $user; Status = "Success"; Note = "License Added" }
    }
    catch {
        $results += [PSCustomObject]@{ User = $user; Status = "Error"; Note = $_.Exception.Message }
        Write-Host "Failed: $user" -ForegroundColor Red
    }
}

# Save the log to your Temp folder
$results | Export-Csv "C:\Temp\LicenseLog.csv" -NoTypeInformation
Write-Host "Process Complete. Log saved to C:\Temp\LicenseLog.csv" -ForegroundColor Green
