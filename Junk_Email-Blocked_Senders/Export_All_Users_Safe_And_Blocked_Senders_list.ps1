<#
.SYNOPSIS
Retrieves Junk Email configuration for all mailboxes and exports the results.

.DESCRIPTION
This script queries all mailboxes in the organization, retrieves their Junk Email
settings, and compiles a report including UserPrincipalName, DisplayName, Enabled,
ContactsTrusted, TrustedSendersAndDomains, and BlockedSendersAndDomains. The report
is displayed in Out-GridView and also exported to a CSV file for further analysis.

.NOTES
Required Module: Exchange Online PowerShell (EXO V2) module.
Replace the CSV path ($CSVpath) as needed for your environment.
All mailbox references use generic names by default.
#>

# Define the path for the CSV output
$CSVpath = "C:\Temp\AllMailboxesJunkEmail.csv"

# Get all mailboxes
$Mailboxes = Get-Mailbox -ResultSize Unlimited

# Initialize an empty list to store output objects
$Report = [System.Collections.Generic.List[Object]]::new()

foreach ($Mailbox in $Mailboxes) {
    # Retrieve Junk Email Configuration for each mailbox
    $JunkEmailConfig = Get-MailboxJunkEmailConfiguration $Mailbox
    
    # Create a custom object for each mailbox's properties
    $ReportLine = [PSCustomObject]@{
        UserPrincipalName        = $Mailbox.UserPrincipalName
        DisplayName              = $Mailbox.DisplayName
        Enabled                  = $JunkEmailConfig.Enabled
        ContactsTrusted          = $JunkEmailConfig.ContactsTrusted
        TrustedSendersAndDomains = ($JunkEmailConfig.TrustedSendersAndDomains -join ',')
        BlockedSendersAndDomains = ($JunkEmailConfig.BlockedSendersAndDomains -join ',')
    }
    
    # Add the properties object to the Report list
    $Report.Add($ReportLine)
}

# Output the mailbox information to Out-GridView
$Report | Sort-Object DisplayName | Out-GridView -Title "Junk Email Options of all mailboxes"

# Export the results to a CSV file
$Report | Sort-Object DisplayName | Export-Csv -Path $CSVpath -NoTypeInformation -Encoding utf8
