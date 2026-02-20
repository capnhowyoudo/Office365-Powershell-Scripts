<#
.SYNOPSIS
Disables mailbox forwarding for a list of users in Exchange.

.DESCRIPTION
This script reads a list of user identities (aliases, usernames, or email
addresses) from a text file and disables mailbox forwarding for each user.

For every entry in the file, the script:

- Clears ForwardingAddress
- Clears ForwardingSmtpAddress
- Sets DeliverToMailboxAndForward to $false

The script processes users sequentially and displays success or warning
messages for each mailbox.

The input file must contain one user identity per line.

.NOTES
Author: capnhowyoudo
Version:       1.0
Requirements:
- Must be run from Exchange Management Shell (EMS) or a session where
  Exchange cmdlets are available
- Requires permissions to run Set-Mailbox

Input:
- Text file located at C:\Temp\users.txt
- One user alias/email per line

Behavior:
- Continues processing even if one mailbox fails
- Uses try/catch for error handling
- Displays colored console output for status

Use Cases:
- Bulk removal of mailbox forwarding
- Security / compliance remediation
- Incident response cleanup
#>

# Define the path to your text file containing user aliases or emails
$userListPath = "C:\Temp\users.txt"

# Check if the file exists
if (Test-Path $userListPath) {
    $users = Get-Content $userListPath

    foreach ($user in $users) {
        Write-Host "Processing user: $user" -ForegroundColor Cyan
        
        try {
            # Set both forwarding parameters to $null and disable DeliverToMailboxAndForward
            Set-Mailbox -Identity $user -ForwardingAddress $null -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false -ErrorAction Stop
            Write-Host "Successfully disabled forwarding for $user" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to update $user. Ensure the identity is correct."
        }
    }
}
else {
    Write-Error "The file at $userListPath was not found. Please create it with one user per line."
}
