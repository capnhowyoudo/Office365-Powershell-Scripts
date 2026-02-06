<#
.SYNOPSIS
Removes a specific Microsoft 365 SKU license from a list of users.

.DESCRIPTION
Reads a list of user IDs from a text file, retrieves the SKU ID for the specified license (E5 Faculty),
and iterates through the list to remove that license from each user. AddLicenses is currently empty.

.NOTES
Requires Microsoft Graph PowerShell module (Mg) and appropriate permissions.
Ensure Connect-MgGraph is run before executing this script.

The accounts file should contain one user principal name (UPN) or user ID per line, for example:
user1@example.com
user2@example.com
user3@example.com

The file path in the script uses C:\Temp\Accounts.txt.

Sku's can be found with this script https://github.com/capnhowyoudo/Office365-Powershell-Scripts/blob/main/Licenses/Get_License_SKU.ps1

Optional Connect to MS Graph Private Window (Some cmdlets may not work, known bug when using  -UseDeviceCode)
Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All -UseDeviceCode
#>

Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All"
$x=Get-Content "C:\Temp\Accounts.txt"
$e5Sku=Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'O365_BUSINESS_ESSENTIALS'
for ($i=0; $i -lt $x.Count; $i++)
{
    Set-MgUserLicense -UserId $x[$i] -RemoveLicenses @($e5Sku.SkuId) -AddLicenses @{}
}
