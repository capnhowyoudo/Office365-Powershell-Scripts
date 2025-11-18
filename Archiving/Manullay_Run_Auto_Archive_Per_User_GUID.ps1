<#
.SYNOPSIS
Retrieves the mailbox GUID and location type for a user mailbox, then starts the Managed Folder Assistant on the primary mailbox using the GUID.

.NOTES
The GUID used in Start-ManagedFolderAssistant should be the Primary Mailbox GUID retrieved from Get-MailboxLocation. 
Replace the generic GUID with the actual primary mailbox GUID of the user.
#>

# Get mailbox GUID and location
Get-MailboxLocation -User user@example.com | FL MailboxGuid, MailboxLocationType

# Start the Managed Folder Assistant on the primary mailbox using the primary GUID
Start-ManagedFolderAssistant 00000000-0000-0000-0000-000000000000
