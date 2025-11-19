<#
.SYNOPSIS
Grant calendar permissions to multiple users in Exchange Online.

.DESCRIPTION
This script assigns a specified access right (e.g., Editor) to one or more users for the calendar folder of a target mailbox. 
The list of users can be provided via a CSV file or an array of email addresses. 

.NOTES
- CSV must have a column named "User" with user email addresses.
- Identity format: <Mailbox>:\<Folder>
- AccessRights can be Editor, Reviewer, Owner, etc.
- Ensure the executing account has permission to assign mailbox folder permissions.
#>

# Example array of delegate users
$Delegates = @("delegate1@example.com","delegate2@example.com")

$TargetMailbox = "user@example.com:\Calendar"
$AccessLevel = "Editor"

# Loop through array and grant permissions
foreach ($user in $Delegates) {
    Add-MailboxFolderPermission -Identity $TargetMailbox -User $user -AccessRights $AccessLevel
}

# Or read from CSV
# CSV format: User
# delegate1@example.com
# delegate2@example.com

$CSVPath = "C:\Temp\Delegates.csv"
Import-Csv $CSVPath | ForEach-Object {
    Add-MailboxFolderPermission -Identity $TargetMailbox -User $_.User -AccessRights $AccessLevel
}
