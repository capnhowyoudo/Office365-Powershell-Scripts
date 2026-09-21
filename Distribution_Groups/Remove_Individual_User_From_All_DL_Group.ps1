# Connect to Exchange Online
Connect-ExchangeOnline

# Define the user to remove
$UserToRemove = "user@domain.com"

# Get all Distribution Groups and Mail-Enabled Security Groups
$AllDLs = Get-DistributionGroup -ResultSize Unlimited

foreach ($DL in $AllDLs) {
    $isMember = Get-DistributionGroupMember -Identity $DL.Identity -ResultSize Unlimited |
        Where-Object { $_.PrimarySmtpAddress -eq $UserToRemove }

    if ($isMember) {
        Write-Host "Removing $UserToRemove from $($DL.DisplayName)" -ForegroundColor Yellow
        Remove-DistributionGroupMember -Identity $DL.Identity -Member $UserToRemove -Confirm:$false
    }
}

Write-Host "Done. Review any errors above." -ForegroundColor Green
