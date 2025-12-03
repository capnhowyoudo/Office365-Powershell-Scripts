<#
.SYNOPSIS
Grants Full Access permission to a mailbox for a specific user.

.DESCRIPTION
This cmdlet assigns Full Access permissions to a mailbox, allowing the specified user
to open and fully manage the mailbox. The -AutoMapping parameter controls whether the
mailbox automatically appears in the user’s Outlook profile.

.NOTES
- Replace "info@company.com" with the mailbox you want to grant access to.
- Replace "user@company.com" with the user who should receive access.
- Set -AutoMapping:$false if you do not want the mailbox to automatically appear in Outlook.

Permissions Overview:

Full Access:
    - Allows a user to open the shared mailbox and manage its contents.
    - Includes the ability to read, delete, and change emails, and create calendar items and tasks.
    - Does not include the ability to send email from the shared mailbox unless combined with other permissions.

Send As:
    - Allows a user to send emails that appear to originate directly from the shared mailbox.
    - For example, an email sent to "info@company.com" would appear to come from "info@company.com".

Send on Behalf:
    - Allows a user to send emails on behalf of the shared mailbox.
    - The email will be sent as "John on behalf of Marketing Department," for example.
#>

# Grant Full Access to a user
Add-MailboxPermission -Identity info@company.com -User user@company.com -AccessRights FullAccess -AutoMapping:$true

# Grant Send As permission to a user
Add-RecipientPermission -Identity info@company.com -Trustee user@company.com -AccessRights SendAs

# Grant Send on Behalf permission to a user
Set-Mailbox -Identity info@company.com -GrantSendOnBehalfTo user@company.com
