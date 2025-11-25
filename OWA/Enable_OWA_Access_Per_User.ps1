<#
.SYNOPSIS
    Enables Outlook on the Web (OWA) access for a specific user's mailbox.

.DESCRIPTION
    This command modifies the Client Access Services (CAS) configuration for the mailbox identified by the -Identity parameter.
    Setting -OWAEnabled to $True explicitly grants the user the ability to access their Exchange mailbox via any web browser interface (Outlook on the Web). This is typically used to restore access after it was previously disabled.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module or Exchange PSSnapin.
    - Context: Granting or restoring a specific client protocol access method for a single user.
    - WARNING: This is a configuration change (Set-) and immediately impacts the user's access methods.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Authenticate to your environment:
       Connect-ExchangeOnline

    2. Run the command below to enable OWA access for the user:
       Set-CASMailbox -Identity "Generic User" -OWAEnabled $True
    
    3. To verify the change, run: Get-CASMailbox -Identity "Generic User" | Format-List OWAEnabled
#>

Set-CASMailbox -Identity "Generic User" -OWAEnabled $True
