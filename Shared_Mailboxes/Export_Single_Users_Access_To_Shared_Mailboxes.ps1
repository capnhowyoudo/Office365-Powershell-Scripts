<#
.SYNOPSIS
Exports mailbox permissions for a specified user across all user mailboxes in Microsoft 365.

.DESCRIPTION
This command retrieves all user mailboxes in the organization, checks for mailbox permissions 
granted to the specified user, and exports the results to a CSV file. The output includes 
the mailbox identity, the user who has been granted access, and the type of access rights. 
This is commonly used for auditing permissions or validating access assignments.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2) module is required.
      Install using: Install-Module ExchangeOnlineManagement

Permission Types Returned:
    FullAccess:
        Allows the user to open the mailbox and manage its contents 
        (read, delete, modify items). Does not include Send As.

    SendAs:
        Allows the user to send emails that appear to come directly from 
        the mailbox identity.

    SendOnBehalf:
        Allows the user to send emails on behalf of the mailbox.  
        Recipients see: "User on behalf of Mailbox".

Additional Notes:
    - Only explicitly assigned permissions are returned (inherited permissions are excluded).
    - Appropriate admin roles are required such as Exchange Administrator or Global Administrator.
    - Replace addresses and file paths with generic or environment-specific placeholders as needed.
#>

Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -eq 'UserMailbox')} | Get-MailboxPermission -User user@example.com | Select Identity, User, AccessRights |Export-CSV -Path "C:\Temp\MailboxPermissions.csv"
