<#
.SYNOPSIS
    Removes a specified user from all Exchange Online distribution groups.

.DESCRIPTION
    This script retrieves all distribution groups (including mail-enabled security groups)
    in Exchange Online and checks each one for membership of a specified user, identified
    by their primary SMTP address. If the user is found as a member, they are removed from
    that group. Each group is referenced by its unique Guid rather than Identity/DisplayName
    to avoid ambiguous match errors when multiple groups share the same name. Errors
    encountered while processing individual groups are caught and displayed as warnings
    without halting the script.

.NOTES
    Requires an active connection to Exchange Online (Connect-ExchangeOnline) and
    sufficient permissions (e.g., Exchange Recipient Administrator) to modify group
    membership.
#>

$UserToRemove = "user@domain.com"
$AllDLs = Get-DistributionGroup -ResultSize Unlimited

foreach ($DL in $AllDLs) {
    try {
        $isMember = Get-DistributionGroupMember -Identity $DL.Guid.ToString() -ResultSize Unlimited |
            Where-Object { $_.PrimarySmtpAddress -eq $UserToRemove }

        if ($isMember) {
            Write-Host "Removing $UserToRemove from $($DL.DisplayName)" -ForegroundColor Yellow
            Remove-DistributionGroupMember -Identity $DL.Guid.ToString() -Member $UserToRemove -Confirm:$false
        }
    } catch {
        Write-Warning "Error processing $($DL.DisplayName) ($($DL.Guid)): $_"
    }
}

Write-Host "Done. Review any errors above." -ForegroundColor Green
