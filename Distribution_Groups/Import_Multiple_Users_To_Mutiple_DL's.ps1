<#
.SYNOPSIS
Adds multiple users from a CSV file to specified Distribution Groups in Exchange Online.

.DESCRIPTION
This script connects to Exchange Online, reads a CSV file containing Distribution Group emails 
and users to add, checks if each user is already a member, and adds them if not. 

CSV Format:
GroupEmail,Users
sales@domain.com,user1@domain.com,user2@domain.com
marketing@domain.com,user3@domain.com,user4@domain.com

.NOTES
- Requires Exchange Online PowerShell module.
- Generic emails are used in this example.
- CSV file should have a header with 'GroupEmail' and 'Users'.
- Users in the 'Users' column are comma-separated if multiple.
#>

# Path to CSV file
$CSVFile = "C:\Temp\DL-Group-Members.csv"

Try {
    # Connect to Exchange Online
    Connect-ExchangeOnline -ShowBanner:$False

    # Import data from CSV
    $CSVData = Import-Csv -Path $CSVFile

    # Iterate through each row
    ForEach ($Row in $CSVData) {

        # Get the Distribution Group
        $Group = Get-DistributionGroup -Identity $Row.GroupEmail

        If ($Group -ne $null) {
            # Get existing members
            $GroupMembers = Get-DistributionGroupMember -Identity $Row.GroupEmail -ResultSize Unlimited |
                            Select-Object -ExpandProperty PrimarySmtpAddress

            # Split users from CSV (comma-separated)
            $UsersToAdd = $Row.Users -split ","

            # Add each user if not already a member
            ForEach ($User in $UsersToAdd) {
                If ($GroupMembers -contains $User) {
                    Write-Host "'$User' is already a member of the group '$($Group.DisplayName)'" -ForegroundColor Yellow
                } else {
                    Add-DistributionGroupMember -Identity $Row.GroupEmail -Member $User
                    Write-Host "Added member '$User' to the group '$($Group.DisplayName)'" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "Could not find group: $($Row.GroupEmail)" -ForegroundColor Red
        }
    }
} Catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
