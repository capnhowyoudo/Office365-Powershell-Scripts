Verify the UPN Sync Feature is Enabled

For older Microsoft Entra directories (created before 2019), the feature that allows UPN changes for managed users to sync from on-premises AD is often disabled by default.
Check the Status (PowerShell)

You need to check the status of the SynchronizeUpnForManagedUsersEnabled feature.

# Requires the Microsoft Graph PowerShell SDK
    Connect-MgGraph -Scopes "OnPremDirectorySynchronization.Read.All"
    
#Check UPN Synchronization Feature Status

    (Get-MgDirectoryOnPremiseSynchronization).Features.SynchronizeUpnForManagedUsersEnabled

If the result is True: Proceed.
  
If the result is False: You must enable the feature.

Enable the Feature (PowerShell)

Use the following command to enable the feature. This change is irreversible.

    $Features = @{ synchronizeUpnForManagedUsersEnabled = $true }
    $Body = @{ features = $Features }
    # Get the unique sync ID
    $SyncId = (Get-MgDirectoryOnPremiseSynchronization).Id
    # Enable the feature
    Update-MgDirectoryOnPremiseSynchronization -OnPremisesDirectorySynchronizationId $SyncId -BodyParameter $Body

Note: Enabling this feature does not retroactively fix existing mismatched UPNs. It only applies to UPN changes made after the feature is enabled. After enabling it, you need to make a new, minor change to the affected user's AD object (like changing the description) and run a delta sync to force a full update for that user.
