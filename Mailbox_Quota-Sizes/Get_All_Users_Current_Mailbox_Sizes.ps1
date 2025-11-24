<#
.SYNOPSIS
Retrieves the mailbox size for all mailboxes (excluding the Discovery Search Mailbox) and exports the results to a CSV file.

.DESCRIPTION
This script retrieves the total mailbox size for all mailboxes in the organization, excluding the "Discovery Search Mailbox". It calculates the size of each mailbox in both the raw format (bytes) and in GB. The results are displayed and exported to a CSV file for further analysis. The script also displays a progress bar for each mailbox processed.

.PARAMETER None
This script does not require any parameters.

.NOTES
Example Usage:
    Run the script to get the mailbox size report for all mailboxes in the organization, excluding the Discovery Search Mailbox, and export the data to `C:\Temp\MailboxSizeRpt.csv`.

This script helps administrators to audit mailbox sizes across the organization, track storage usage, and generate reports for further action.

#>

# Get all mailboxes, excluding the "Discovery Search Mailbox"
$AllMailboxes = Get-MailBox -ResultSize Unlimited | Where {$_.DisplayName -ne "Discovery Search Mailbox"}
$Result = @()
$Counter = 1
$TotalMailboxes =  $AllMailboxes.Count

# Loop through each mailbox
ForEach ($Mailbox in $AllMailboxes) {
    # Display progress bar
    Write-Progress -PercentComplete (($Counter/$TotalMailboxes)*100) -Status "Processing Mailbox $($Mailbox.PrimarySMTPAddress)" -Activity "Getting Mailbox Size ($Counter of $TotalMailboxes)"

    # Get the mailbox size in bytes
    $MailboxSize = (Get-MailboxStatistics -Identity $Mailbox.UserPrincipalName).TotalItemSize
    # Convert size to GB (if it contains 'bytes')
    $MailboxSizeinGB = [math]::Round(($MailboxSize -replace "(.*\()|,| [a-z]*\)", "")/1GB, 2)
    
    # Add the results to the collection
    $Result += (
        New-Object psobject -Property @{
            'Display Name'      = $Mailbox.DisplayName
            'Email Address'     = $Mailbox.PrimarySMTPAddress
            'Mailbox Size'      = $MailboxSize
            'Mailbox Size (GB)' = $MailboxSizeinGB
        }
    )
    $Counter++
}

# Output the results to the console
$Result

# Export the mailbox storage size report to CSV
$Result | Export-CSV -Path "C:\Temp\MailboxSizeRpt.csv" -NoTypeInformation
Write-Host "Mailbox size report exported to C:\Temp\MailboxSizeRpt.csv"
