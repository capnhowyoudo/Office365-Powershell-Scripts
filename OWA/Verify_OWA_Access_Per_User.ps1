<#
.SYNOPSIS
    Retrieves the Client Access Services (CAS) configuration settings for a specific mailbox.

.DESCRIPTION
    This command retrieves the current protocol access settings for the mailbox identified by the -Identity parameter.
    CAS settings control which client protocols are enabled or disabled for the user, including Outlook on the Web (OWA), POP3, IMAP4, MAPI, and ActiveSync. This is often the first step when troubleshooting or auditing a user's access methods.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module or Exchange PSSnapin.
    - Context: Mailbox auditing, verifying or preparing to modify client protocol access controls.
    - The output is typically piped to 'fl' (Format-List) to view all settings cleanly.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Authenticate to your environment:
       Connect-ExchangeOnline

    2. Run the command below to inspect a user's CAS settings:
       Get-CASMailbox -Identity "Generic User" | Format-List *Enabled

    3. You can modify settings using the corresponding Set-CASMailbox cmdlet.
#>

Get-CASMailbox -Identity "Generic User"
