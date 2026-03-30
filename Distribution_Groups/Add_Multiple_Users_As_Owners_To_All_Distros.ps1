<#
.SYNOPSIS
Adds multiple specified users as owners to all Exchange Online distribution groups.

.DESCRIPTION
This script connects to Exchange Online, retrieves all distribution groups, and adds a predefined list of users as owners to each group.
It preserves existing owners by using the @{Add=...} syntax and bypasses the security group manager check to ensure changes can be applied.
Errors are handled per group to prevent the script from stopping prematurely.

.NOTES
Requirements:
- Exchange Online PowerShell module
- Appropriate permissions to modify distribution groups

Usage:
- Update the $NewOwners array with valid Primary SMTP addresses before running.
- Run in a PowerShell session with Exchange Online connectivity.
#>

# 1. Connect to Exchange Online
Connect-ExchangeOnline

# 2. Define the users you want to add as owners (Use Primary SMTP addresses)
$NewOwners = @(
    "admin1@yourdomain.com",
    "admin2@yourdomain.com",
    "manager@yourdomain.com"
)

# 3. Get all Distribution Groups
$AllGroups = Get-DistributionGroup -ResultSize Unlimited

Write-Host "Starting update for $($AllGroups.Count) groups..." -ForegroundColor Cyan

foreach ($Group in $AllGroups) {
    Write-Host "Updating owners for: $($Group.DisplayName)" -ForegroundColor Yellow
    
    # We use -ManagedBy to add the new owners. 
    # The @{Add=...} syntax ensures we add them without removing existing owners.
    try {
        Set-DistributionGroup -Identity $Group.ExternalDirectoryObjectId `
                              -ManagedBy @{Add=$NewOwners} `
                              -BypassSecurityGroupManagerCheck `
                              -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to update $($Group.DisplayName): $($_.Exception.Message)"
    }
}

Write-Host "Process Complete!" -ForegroundColor Green

# 4. Disconnect
Disconnect-ExchangeOnline -Confirm:$false
