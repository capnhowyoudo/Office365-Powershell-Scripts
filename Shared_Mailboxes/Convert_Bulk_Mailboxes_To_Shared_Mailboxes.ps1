<#
.SYNOPSIS
Converts multiple Microsoft 365 user mailboxes to shared mailboxes using a CSV input file.

.DESCRIPTION
This script reads a CSV file containing a list of mailbox email addresses and checks each mailbox:
    - If the mailbox does not exist, it records the error.
    - If the mailbox is already a shared mailbox, it notifies the user.
    - If the mailbox is a user mailbox, it converts it to a shared mailbox.
The script then validates the conversion and outputs the result to the console.

.PARAMETER MailboxNames
Specifies the path to the CSV file that contains the list of mailbox email addresses.
The CSV file must have a column named "Email".

CSV Format Required:
    Email
    user1@example.com
    user2@example.com
    
Save in C:\temp\bulk.csv

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - Conversion requires Exchange Administrator permissions.
    - Mailboxes converted to shared mailboxes no longer require licenses (depending on workload usage).
    - The script uses ErrorAction SilentlyContinue to avoid termination on failures.
    
Verification:
    After running the script, you can verify mailbox types using:
    Import-Csv "C:\temp\bulk.csv" | foreach {Get-Mailbox -Identity $_.Email} | ft Name, RecipientTypeDetails
#>

$MailboxNames = "C:\temp\bulk.csv"

Import-Csv $MailboxNames | foreach {
    $Email = $_.Email
    $Mailbox = Get-Mailbox -Identity $email -ErrorAction SilentlyContinue

    if ($null -eq $Mailbox) {
        Write-Host "Mailbox '$email' not found." -ForegroundColor Red
    }
    elseif ($Mailbox.RecipientTypeDetails -eq "SharedMailbox") {
        Write-Host "Mailbox '$Email' is already a shared mailbox." -ForegroundColor Cyan
    }
    else {
        Set-Mailbox -Identity $Email -Type Shared -ErrorAction SilentlyContinue

        $UpdatedMailbox = Get-Mailbox -Identity $Email

        if ($UpdatedMailbox.RecipientTypeDetails -eq "SharedMailbox") {
            Write-Host "Mailbox '$Email' converted to a shared mailbox successfully." -ForegroundColor Green
        }
        else {
            Write-Host "Failed to convert mailbox '$Email' to a shared mailbox." -ForegroundColor Red
        }
    }
}
