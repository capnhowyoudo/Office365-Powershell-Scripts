<#
.SYNOPSIS
    Grants the permissions required to export mailbox content from Microsoft Purview
    eDiscovery searches to a specified user.

.DESCRIPTION
    - Connects to Security & Compliance PowerShell
    - Adds the user to the built-in "eDiscovery Manager" role group, which includes
      the Export, Preview, Compliance Search, Hold, and RMS Decrypt roles
    - Optionally adds the user as a member/admin of a specific eDiscovery case
      (required for eDiscovery (Premium) cases, where permissions are case-scoped)

.NOTES
    Requires:
      - ExchangeOnlineManagement module (v3+)
      - The account running this script must be an Organization Management /
        RoleManagement admin (able to modify role groups)
#>

# -------------------- CONFIGURATION --------------------
$UserToGrant = "admin@contoso.onmicrosoft.com"
$CaseName    = $null   # Set this to a specific eDiscovery (Premium) case name if applicable, e.g. "Case-2025-001"
# ---------------------------------------------------------

Import-Module ExchangeOnlineManagement

Write-Host "Connecting to Security & Compliance Center..." -ForegroundColor Cyan
Connect-IPPSSession

# 1. Add user to the "eDiscovery Manager" role group (grants Export role org-wide,
#    for Content Search / eDiscovery Standard scenarios)
#    NOTE: The role group's internal Name is "eDiscoveryManager" (no space) even
#    though its DisplayName is "eDiscovery Manager" (with a space). Add-RoleGroupMember
#    requires the internal Name/Identity, not the display name, or it throws
#    ManagementObjectNotFoundException.
$RoleGroupIdentity = "eDiscoveryManager"

Write-Host "Adding $UserToGrant to '$RoleGroupIdentity' role group..." -ForegroundColor Cyan
Add-RoleGroupMember -Identity $RoleGroupIdentity -Member $UserToGrant

# 2. Verify membership
Write-Host "`nCurrent members of '$RoleGroupIdentity':" -ForegroundColor Cyan
Get-RoleGroupMember -Identity $RoleGroupIdentity | Select-Object Name, RecipientType

# 3. If using an eDiscovery (Premium) case, permissions are scoped per-case.
#    Add the user as a case member/admin so they can export within that case.
if ($CaseName) {
    Write-Host "`nAdding $UserToGrant as an admin on case '$CaseName'..." -ForegroundColor Cyan
    Add-ComplianceCaseMember -Case $CaseName -Member $UserToGrant

    Write-Host "Current members of case '$CaseName':" -ForegroundColor Cyan
    Get-ComplianceCaseMember -Case $CaseName
}

Write-Host "`nDone. Note: Role group membership changes can take up to 30-60 minutes to fully propagate." -ForegroundColor Yellow
