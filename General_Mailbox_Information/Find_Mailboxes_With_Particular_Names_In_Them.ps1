<#
.SYNOPSIS
    Exports Exchange Online mailboxes containing "mgmt" in their SMTP address to a CSV file.

.DESCRIPTION
    This script connects to Exchange Online, retrieves all mailboxes, and filters them based on whether 
    the Primary SMTP Address contains the string "mgmt". The resulting list includes the display name, 
    UPN, primary email, mailbox type, and creation date, which is then saved to a local CSV file.

.NOTES
    - Prerequisites: Requires the ExchangeOnlineManagement PowerShell module.
    - Permissions: Must have sufficient administrative permissions.
    - File Path: Ensure the "C:\Temp" directory exists before running.
    - Customization: Change the "mgmt" string in the Where-Object filter to the specific keyword you are looking for.
#>

# Connect to Exchange Online
Connect-ExchangeOnline

# Get mailboxes with "mgmt" in the email address
$mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {
    $_.PrimarySmtpAddress -like "*mgmt*"
}

# Select properties you want in the CSV
$mailboxes | Select-Object `
    DisplayName,
    UserPrincipalName,
    PrimarySmtpAddress,
    RecipientTypeDetails,
    WhenCreated |
Export-Csv -Path "C:\Temp\MgmtMailboxes.csv" -NoTypeInformation

Write-Host "Export complete: C:\Temp\MgmtMailboxes.csv"
