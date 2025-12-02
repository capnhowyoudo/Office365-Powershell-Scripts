The UPN Sync Feature is a critical setting in Microsoft Entra ID (formerly Azure AD) that controls whether changes to a user's User Principal Name (UPN) in your on-premises Active Directory are successfully synchronized and applied to the corresponding user account in the cloud

Historically, Microsoft blocked the synchronization of UPN updates from on-premises AD to the cloud for users who met two specific criteria:

They were using Managed Authentication (Password Hash Sync or Pass-through Authentication, not Federation).

They had an Office 365/Microsoft 365 license assigned.

This meant that if an administrator changed a licensed user's UPN in Active Directory (e.g., from john.smith@olddomain.com to john.smith@newdomain.com), the change would not flow to Microsoft Entra ID. The user's cloud sign-in name would remain the old one, causing a UPN mismatch.

The UPN Sync Feature solves this problem:

Enabling the Feature (-Enable $True) allows Microsoft Entra Connect (the sync engine) to successfully update the UserPrincipalName attribute in the cloud whenever it is changed in the on-premises Active Directory, even for managed and licensed users.

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
