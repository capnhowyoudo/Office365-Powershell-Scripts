<#
.SYNOPSIS
    Exports Exchange Online mailboxes containing "mgmt" along with Full Access and Send As permissions.

.DESCRIPTION
    This script connects to Exchange Online and retrieves all mailboxes where the Primary SMTP Address 
    contains the string "mgmt". For each matching mailbox, it audits explicit "Full Access" permissions 
    (filtering out inherited and self-assigned rights) and "Send As" permissions. The data, including 
    the creation date and UPN, is سپس exported to a CSV file for administrative review.

.NOTES
    - Prerequisites: Requires the ExchangeOnlineManagement PowerShell module installed.
    - Permissions: Must be executed by a user with Exchange Administrator or Global Administrator roles.
    - Customization: Update the "*mgmt*" filter in the Where-Object block to match different naming standards.
    - Path: Ensure 'C:\Temp' exists or modify the Export-Csv path to a valid local directory.
#>

# Connect to Exchange Online
Connect-ExchangeOnline

# Get mailboxes with "mgmt" in the email address
$mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {
    $_.PrimarySmtpAddress -like "*mgmt*"
}

$results = foreach ($mb in $mailboxes) {

    # Get Full Access users
    $fullAccess = Get-MailboxPermission -Identity $mb.Identity |
        Where-Object {
            $_.AccessRights -contains "FullAccess" -and
            $_.IsInherited -eq $false -and
            $_.User -notlike "NT AUTHORITY\SELF"
        } |
        Select-Object -ExpandProperty User

    # Get Send-As users
    $sendAs = Get-RecipientPermission -Identity $mb.Identity |
        Where-Object {
            $_.AccessRights -contains "SendAs"
        } |
        Select-Object -ExpandProperty Trustee

    # Output object
    [PSCustomObject]@{
        DisplayName           = $mb.DisplayName
        UserPrincipalName     = $mb.UserPrincipalName
        PrimarySmtpAddress    = $mb.PrimarySmtpAddress
        RecipientTypeDetails  = $mb.RecipientTypeDetails
        WhenCreated           = $mb.WhenCreated
        FullAccessMembers     = ($fullAccess -join "; ")
        SendAsMembers         = ($sendAs -join "; ")
    }
}

# Export to CSV
$results | Export-Csv -Path "C:\Temp\MgmtMailboxes_WithMembers.csv" -NoTypeInformation

Write-Host "Export complete: C:\Temp\MgmtMailboxes_WithMembers.csv"
