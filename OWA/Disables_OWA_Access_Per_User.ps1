<#
.SYNOPSIS
    Disables Outlook on the Web (OWA) access for a specific user's mailbox.

.DESCRIPTION
    This command modifies the Client Access Services (CAS) configuration for the mailbox identified by the -Identity parameter.
    Setting -OWAEnabled to $False immediately revokes the user's ability to access their Exchange mailbox via any web browser interface (Outlook on the Web). This is a common security control for specific users.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module or Exchange PSSnapin.
    - Context: Disabling a specific client protocol access method for a single user.
    - WARNING: This is a configuration change (Set-) and immediately impacts the user's access methods.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Authenticate to your environment:
       Connect-ExchangeOnline

    2. Run the command below to disable OWA access for the user:
       Set-CASMailbox -Identity "Generic User" -OWAEnabled $False
    
    3. To re-enable access, change $False to $True.
#>

Set-CASMailbox -Identity "Generic User" -OWAEnabled $False
