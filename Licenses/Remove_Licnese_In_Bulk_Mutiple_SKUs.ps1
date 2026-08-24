<#
.SYNOPSIS
    Removes specific Microsoft 365 license SKUs from a list of users.

.DESCRIPTION
    Connects to Microsoft Graph and bulk-removes a predefined set of license SKUs
    (by SKU part number) from users listed in an input text file. The script:
      - Retrieves all subscribed SKUs in the tenant and matches them against the
        target SKU part number list, warning about any that are not found.
      - For each user, retrieves their currently assigned licenses and only
        attempts to remove SKUs that are both in the target list and actually
        assigned to that user.
      - Skips users who have none of the target licenses assigned.
      - Reports success, skip, or failure status for each user to the console.

    Input file format: a plain text file with one user identifier
    (UserPrincipalName or User ID) per line.

.NOTES
    Author          : 
    Requires        : Microsoft.Graph.Users, Microsoft.Graph.Users.Actions PowerShell modules
    Required scopes : User.ReadWrite.All, Directory.ReadWrite.All
    Input file       : C:\Temp\Accounts.txt (one UPN or User ID per line)
    Last updated    : 
    Caution         : This script modifies user license assignments in Microsoft 365.
                      Test in a non-production tenant or with a small user list first.
#>

Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All" -UseDeviceAuthentication
$x = Get-Content "C:\Temp\Accounts.txt"
# List of SKU part numbers to remove
$skuPartNumbers = @(
    'EMSPREMIUM',
    'THREAT_INTELLIGENCE',
    'ENTERPRISEPREMIUM',
    'WINDOWS_STORE',
    'FLOW_FREE',
    'SPB',
    'NONPROFIT_PORTAL',
    'PBI_PREMIUM_PER_USER',
    'AAD_PREMIUM',
    'STANDARDPACK'
)
$allSkus = Get-MgSubscribedSku -All
$skusToRemove = $allSkus | Where-Object { $_.SkuPartNumber -in $skuPartNumbers }
$missing = $skuPartNumbers | Where-Object { $_ -notin $skusToRemove.SkuPartNumber }
if ($missing) {
    Write-Warning "The following SKUs were not found in this tenant and will be skipped: $($missing -join ', ')"
}
foreach ($user in $x) {
    try {
        # Get this user's currently assigned license SKU IDs
        $currentSkuIds = (Get-MgUserLicenseDetail -UserId $user -ErrorAction Stop).SkuId
        # Only remove SKUs that are BOTH in our target list AND actually assigned to this user
        $skuIdsToRemove = @($skusToRemove | Where-Object { $_.SkuId -in $currentSkuIds } | Select-Object -ExpandProperty SkuId)
        if ($skuIdsToRemove.Count -eq 0) {
            Write-Host "Skipped $user - no matching licenses assigned" -ForegroundColor Yellow
            continue
        }
        Set-MgUserLicense -UserId $user -RemoveLicenses $skuIdsToRemove -AddLicenses @{}
        Write-Host "Removed licenses from $user" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to update $user : $_"
    }
}
