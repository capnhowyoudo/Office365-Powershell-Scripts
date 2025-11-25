<#
.SYNOPSIS
    Disables Outlook on the Web (OWA) access for all standard user mailboxes, excluding administrators.

.DESCRIPTION
    This command performs a bulk configuration change:
    1. It uses Get-User to retrieve all user objects in the organization.
    2. It filters (Where-Object) to include only standard 'UserMailbox' types.
    3. It then applies a secondary filter to exclude any user whose Active Directory 'Title' property is set to 'Exchange Admin', ensuring administrators are not locked out.
    4. The remaining mailboxes are piped to Set-CASMailbox, which disables OWA access by setting -OWAEnabled to $False.

.NOTES
    - Dependency: Requires the ExchangeOnlineManagement Module or Exchange PSSnapin (depending on environment).
    - Context: Security hardening or enforcing the use of desktop/mobile clients over web access.
    - WARNING: This command immediately revokes web access for all targeted users. Test on a small group first.
    
    --------------------------
    EXAMPLE USAGE
    --------------------------
    1. Authenticate to your environment:
       Connect-ExchangeOnline

    2. Run the command below to disable OWA access for all standard users (excluding 'Exchange Admin' titles):
       Get-User | Where-Object {($_.RecipientTypeDetails -eq 'UserMailbox') -and ($_.Title -ne ‘Exchange Admin’)} | Set-CASMailbox -OWAEnabled $False
#>

Get-User | Where-Object {($_.RecipientTypeDetails -eq 'UserMailbox') -and ($_.Title -ne ‘Exchange Admin’)} | Set-CASMailbox -OWAEnabled $False
