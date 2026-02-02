# ⚠️ WARNING/DISCLAIMER: Data Loss Risk 

IMPACT OF HARD DELETION: The hard deletion in Phase 1, Step 6 is permanent and bypasses the Azure AD Recycle Bin. If the GUID of the wrong user object (especially one holding the primary cloud mailbox/data) is used in the Remove-MgDirectoryDeletedItem cmdlet, it will result in the immediate and irreversible loss of all associated data, including the user's Exchange mailbox, OneDrive content, and SharePoint permissions. Always verify the object's identity before executing this command. Proceed with extreme caution.

# About

This process is specifically used to merge two existing user accounts belonging to the same person:
  
  - The original cloud-only account (which typically holds the user's Exchange mailbox and OneDrive data).
  
  - The newly created/existing on-premises AD account (which is the intended source of authority).
  
   By resetting the Immutable ID (Source Anchor) of the cloud object to match the on-premises AD object's ObjectGUID, you force a Hard Match during synchronization, thus merging them into a single, synchronized identity.

# Prerequisites

  - Administrative access to On-Premises Active Directory (AD) (e.g., domain: contoso.local).

  - Administrative access to Microsoft 365 (M365)/Azure AD (e.g., UPN suffix: example.com).

  - PowerShell with the Microsoft Graph SDK module installed and the necessary permissions granted (User.ReadWrite.All, Organization.Read.All).

# Note

It is ideal to run all cmdlets on the server that houses Active Directory and Azure AD Connect Synchronization for consistent results.

If Azure AD Connect is not installed on the DC, the necessary synchronization commands can be executed remotely to avoid logging onto the AD Connect server. 

Remove "SERVERNAME" Replace with the name of the server that has your Entra Connect installed. 

Replace the below cmdlet in Step 3 & 9 if needed. 

    Invoke-Command -ComputerName SERVERNAME -ScriptBlock { Import-Module ADSync; Start-ADSyncSyncCycle -PolicyType Delta }

# Phase 1: Initiate Deletion and Verify

  1. In AD: Remove the user account from the synchronized Organizational Unit (OU) by moving it to a non-syncing OU. This initiates the soft-deletion process for the on-premises object in Azure AD.

  2. In PowerShell:  Connect to the Microsoft Graph.

    Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All

  3. In PowerShell: Manually start a delta synchronization cycle to push the user's OU change to Azure AD.

    Start-ADSyncSyncCycle -PolicyType Delta

  4. In M365/Azure AD: Verify the on-premises object is soft-deleted by confirming it appears in the "Deleted users" list in the M365 admin center.

  5. In Powershell: Reterive the Direcoty ObjectID GUID of the deleted account

    Get-MgDirectoryDeletedItemAsUser

  6. In PowerShell: Hard-delete the soft-deleted object from the Azure AD recycle bin. This step is critical because a soft-deleted object may still hold the desired Immutable ID, preventing the hard match in Phase 2.

     - Note: The DirectoryObjectId is the unique GUID of the deleted user. Replace the placeholder below with the actual GUID you find in step 5

    Remove-MgDirectoryDeletedItem -DirectoryObjectId AAAAAAA0-0000-0000-0000-000000000000

# Phase 2: Recalculate and Apply Immutable ID (Hard Match)

  7. In PowerShell: Run the following commands to calculate the new Base64-encoded GUID from the on-premises user object and apply it to the existing cloud-only user's object, thus resetting the ImmutableID attribute (which is also known as SourceAnchor).

  Placeholder Value Replacement:
  - Replace jdoe with the user's on-premises SAM account name.
  - Replace jdoe@example.com with the user's cloud UPN.

        $guid = (Get-ADUser jdoe).ObjectGuid
        $immutableID = [System.Convert]::ToBase64String($guid.tobytearray())
        Update-MgUser -UserId jdoe@example.com -OnPremisesImmutableId $immutableID

  This command links the existing cloud-only account (jdoe@example.com) to the on-premises source account (jdoe)

# Phase 3: Re-synchronization

  8. In AD: Move the user back to the synchronized OU. This signals to Azure AD Connect that the user should be included in the next synchronization.

  9. In PowerShell: Manually start a delta synchronization cycle to complete the process. This will match the on-premises user object (now with the updated Immutable ID) with the cloud object, completing the merge.

    Start-ADSyncSyncCycle -PolicyType Delta  

  10. In PowerShell: Disconnect the Microsoft Graph session.

    disconnect-mgraph
    
