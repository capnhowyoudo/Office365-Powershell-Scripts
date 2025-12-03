<#
.SYNOPSIS
Runs a Delta synchronization cycle on a remote server using Azure AD Connect.

.DESCRIPTION
This command uses PowerShell Remoting to connect to the specified remote server,
loads the ADSync module within that remote session, and triggers a Delta sync cycle.
A Delta sync processes only changes since the last synchronization and is used for
routine update cycles in Azure AD Connect.

.NOTES
Replace SERVERNAME with the hostname of the server where Entra Connect (Azure AD Connect) is installed.

Sync policy types:

    Delta Sync: Synchronizes only changes made since the last sync cycle; efficient for routine updates.
    Full Sync: Imports and synchronizes all data; used after major configuration changes such as modified sync rules.
    Initial Sync: A Start-ADSyncSyncCycle policy type that forces a full synchronization cycle; equivalent to a Full Sync for this command.
#>

Invoke-Command -ComputerName SERVERNAME -ScriptBlock { Import-Module ADSync; Start-ADSyncSyncCycle -PolicyType Delta }
