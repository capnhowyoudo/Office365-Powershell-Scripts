<#
.SYNOPSIS
Adds users from a CSV file to a specified Distribution Group in Exchange Online.

.DESCRIPTION
This script connects to Exchange Online, retrieves the current members of a specified 
Distribution Group, and imports additional members from a CSV file. It checks if each user
is already a member before attempting to add them. 

.NOTES
- Requires Exchange Online PowerShell module.
- CSV file must contain a column with user emails (UPN). Example header: "UPN".
- Generic emails are used for demonstration purposes.
- CSV example format:
  UPN
  user1@domain.com
  user2@domain.com
- Make sure the C:\Temp folder exists or modify the path accordingly.
#>

# -----------------------------------------------------------
# Configuration
# -----------------------------------------------------------

# Distribution Group Email (use generic email)
$GroupEmailID = "staff@domain.com"

# Path to CSV file containing UPNs of users to add
$CSVFile = "C:\Temp\DL-Members.csv"

# -----------------------------------------------------------
# Connect to Exchange Online
# -----------------------------------------------------------
Connect-ExchangeOnline -ShowBanner:$False

# -----------------------------------------------------------
# Get Existing Members of the Distribution List
# -----------------------------------------------------------
$DLMembers = Get-DistributionGroupMember -Identity $GroupEmailID -ResultSize Unlimited | 
             Select-Object -ExpandProperty PrimarySmtpAddress

# -----------------------------------------------------------
# Import Distribution List Members from CSV
# -----------------------------------------------------------
Import-Csv $CSVFile -Header "UPN" | ForEach-Object {
    $UserUPN = $_.UPN

    # Check if user is already a member
    if ($DLMembers -contains $UserUPN) {
        Write-Host "User is already a member of the Distribution List: $UserUPN" -ForegroundColor Yellow
    } else {
        # Add user to the distribution group
        Add-DistributionGroupMember -Identity $GroupEmailID -Member $UserUPN
        Write-Host "Added User to Distribution List: $UserUPN" -ForegroundColor Green
    }
}
