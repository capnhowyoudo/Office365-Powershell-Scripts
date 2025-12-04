<#
.SYNOPSIS
Initiates an initial Azure AD Connect synchronization cycle.

.DESCRIPTION
This script imports the ADSync module and triggers an Initial synchronization
cycle using Azure AD Connect. An Initial sync processes all objects and attributes,
making it more comprehensive and typically longer than a Delta sync. This is
useful when configuration changes have been made that require a full re-sync.

.NOTES
Sync policy types:

    Delta Sync: Synchronizes only changes made since the last sync cycle; efficient for routine updates.
    Full Sync: Imports and synchronizes all data; used after major configuration changes such as modified sync rules.
    Initial Sync: A Start-ADSyncSyncCycle policy type that forces a full synchronization cycle; equivalent to a Full Sync for this command.
#>

Import-Module ADSync; Start-ADSyncSyncCycle -PolicyType Initial
