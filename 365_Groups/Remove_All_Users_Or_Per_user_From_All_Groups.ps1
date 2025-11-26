#Requires -Version 3.0
#Requires -Modules @{ ModuleName="ExchangeOnlineManagement"; ModuleVersion="3.0.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Groups"; ModuleVersion="1.19.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="1.19.0" }

[CmdletBinding(SupportsShouldProcess)] #Make sure we can use -WhatIf and -Verbose
Param([ValidateNotNullOrEmpty()][Alias("UserToRemove")][String[]]$Identity,[switch]$IncludeAADSecurityGroups,[switch]$IncludeOffice365Groups,[switch]$Quiet)

#For details on what the script does and how to run it, check: https://www.michev.info/blog/post/4409/remove-user-from-all-microsoft-365-groups-updated-2023-version-of-the-script

#Add switch to handle situations where the user is the only owner of a Group?
#Handle privileged AAD groups


function Check-Connectivity {
    [cmdletbinding()]
    [OutputType([bool])]
    param([switch]$IncludeAADSecurityGroups)

    #IF using the IncludeAADSecurityGroups parameter
    if ($IncludeAADSecurityGroups) {
        Write-Verbose "Checking connectivity to Graph PowerShell..."
        try {
            if (!(Get-MgContext) -or !((Get-MgContext).Scopes.Contains("Group.ReadWrite.All"))) {
                Write-Verbose "Not connected to the Microsoft Graph or the required permissions are missing!"
                Connect-MgGraph -Scopes Directory.Read.All,Group.ReadWrite.All -ErrorAction Stop | Out-Null
                if ((Get-Module "Microsoft.Graph.Users").Version.Major -eq 1) { Select-MgProfile beta -ErrorAction Stop -WhatIf:$false } #needed for the filter stuff
            }
        }
        catch { Write-Error $_; return $false }
        #Double-check required permissions
        if (!((Get-MgContext).Scopes.Contains("Group.ReadWrite.All"))) { Write-Error "The required permissions are missing, please re-consent!"; return $false }
    }

    #Make sure we are connected to Exchange Online PowerShell
    Write-Verbose "Checking connectivity to Exchange Online PowerShell..."

    #Check via Get-ConnectionInformation first
    if (Get-ConnectionInformation) { return $true }

    #Double-check and try to eastablish a session
    try { Get-EXORecipient -ResultSize 1 -ErrorAction Stop | Out-Null }
    catch {
        try { Connect-ExchangeOnline -CommandName Get-EXORecipient, Get-User, Remove-DistributionGroupMember, Remove-UnifiedGroupLinks -SkipLoadingFormatData } #custom for this script
        catch { Write-Error "No active Exchange Online session detected. To connect to ExO: https://docs.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell?view=exchange-ps"; return $false }
    }

    return $true
}

function Remove-UserFromAllGroups {

<#
.SYNOPSIS
Removes one or more users from all Microsoft 365 groups, including Exchange, Office 365, and optionally Azure AD Security groups.

.DESCRIPTION
The Remove_User(s)_From_All_Groups.ps1 script allows administrators to remove specified users from all types of groups in the organization.
It supports Exchange Online, Microsoft 365 Groups, and optionally Azure AD Security groups.
The script can accept users via parameter input, pipeline input, or CSV for bulk operations.
It supports -WhatIf and -Verbose switches to simulate actions and provide detailed execution information.
You can export the results to a CSV file for auditing purposes.

.NOTES
Script Name: Remove_User(s)_From_All_Groups.ps1
Author: Vasil Michev
Version: 1.0
Requires: ExchangeOnlineManagement >= 3.0.0, Microsoft.Graph.Users >= 1.19.0, Microsoft.Graph.Groups >= 1.19.0
Execution Policy: RemoteSigned or higher
More info: https://www.michev.info/blog/post/4409/remove-user-from-all-microsoft-365-groups-updated-2023-version-of-the-script

.PARAMETER Identity
The UPN, email address, alias, or user identifier of the user(s) to remove from all groups. Supports multiple users via array or pipeline input.

.PARAMETER IncludeAADSecurityGroups
Include Azure AD Security Groups in the removal process.

.PARAMETER IncludeOffice365Groups
Include Office 365 Groups in the removal process.

.PARAMETER Quiet
Suppress console output but still logs to CSV.

.PARAMETER WhatIf
Simulates the removal actions without making changes.

.PARAMETER Verbose
Shows detailed progress and troubleshooting information.

.EXAMPLE
Remove a single user from all applicable groups:
.Remove_All_Users_Or_Per_user_From_All_Groups.ps1 -Identity "user1@contoso.com" -IncludeAADSecurityGroups -IncludeOffice365Groups

.EXAMPLE
Remove multiple users using an array:
.Remove_All_Users_Or_Per_user_From_All_Groups.ps1 -Identity "user1@contoso.com","user2@contoso.com" -IncludeOffice365Groups

.EXAMPLE
Remove multiple users using a CSV file:

Create a CSV file UsersToRemove.csv with the header UserPrincipalName:
UserPrincipalName
user1@contoso.com
user2@contoso.com
user3@contoso.com

Place Both The Script and csv into the same folder C:\Scripts

Run the script: 
Remove -WhatIf after testing

cd c:\Scripts
$csv = Import-Csv .\nameofyoursheet.csv
.\Remove_All_Users_Or_Per_user_From_All_Groups.ps1 -Identity $csv.UserPrincipalName -WhatIf -Verbose -IncludeOffice365Groups

.EXAMPLE
Test the removal actions without actually removing users:
.\Remove_All_Users_Or_Per_user_From_All_Groups.ps1 -Identity "user1@contoso.com" -IncludeOffice365Groups -WhatIf

.DESCRIPTION STEPS
Step 1: Ensure required modules are installed and updated:
- ExchangeOnlineManagement >= 3.0.0
- Microsoft.Graph.Users >= 1.19.0
- Microsoft.Graph.Groups >= 1.19.0

Step 2: Prepare a list of users manually or via CSV as described in the examples.

Step 3: Execute the script with desired switches (-IncludeAADSecurityGroups, -IncludeOffice365Groups, -Quiet, -WhatIf, -Verbose).

Step 4: Review the output or exported CSV to confirm the removal actions.

#>
    [CmdletBinding(SupportsShouldProcess=$true)]

    Param
    (
    <#The Identity parameter specifies the identity of the user object.

This parameter accepts the following values:
* Alias: JPhillips
* Display Name: Jeff Phillips
* Distinguished Name (DN): CN=JPhillips,CN=Users,DC=Atlanta,DC=Corp,DC=contoso,DC=com
* GUID: fb456636-fe7d-4d58-9d15-5af57d0354c2
* Legacy Exchange DN: /o=Contoso/ou=AdministrativeGroup/cn=Recipients/cn=JPhillips
* SMTP Address: Jeff.Phillips@contoso.com
* User Principal Name: JPhillips@contoso.com
        #>
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ValueFromRemainingArguments=$false)]
        [ValidateNotNullOrEmpty()][Alias("UserToRemove")][String[]]$Identity,
        [switch]$IncludeAADSecurityGroups,
        [switch]$IncludeOffice365Groups,
        [switch]$Quiet)

    Begin {
        #Check if we are connected to Exchange Online/Graph PowerShell...
        if (Check-Connectivity -IncludeAADSecurityGroups:$IncludeAADSecurityGroups) { Write-Verbose "Parsing the Identity parameter..." }
        else { Write-Host "ERROR: Connectivity test failed, exiting the script..." -ForegroundColor Red; continue }

        $out = @() #If you instantiate $out in the process block, it gets overwritten when using the pipeline...
    }

    Process {
        #Needed to handle pipeline input
        $GUIDs = @{};

        foreach ($us in $Identity) {
            Start-Sleep -Milliseconds 80 #Add some delay to avoid throttling...
            #Make sure a matching user object is found and return its DN. While we can handle other object type easily on Exchange side, on AAD side we need additional cmdlets, checks, etc...
            #$GUID = Get-User $us -Filter {RecipientType -eq 'User' -or RecipientType -eq 'UserMailbox' -or RecipientType -eq 'MailUser'} | Select-Object DistinguishedName,ExternalDirectoryObjectId #silence these errors or?
            $GUID = Get-User $us | Select-Object DistinguishedName,ExternalDirectoryObjectId #silence these errors or?
            if (!$GUID) { Write-Verbose "Security principal with identifier $us not found, skipping..."; continue }
            elseif (($GUID.count -gt 1) -or ($GUIDs[$us]) -or ($GUIDs.ContainsValue($GUID))) { Write-Verbose "Multiple users matching the identifier $us found, skipping..."; continue }
            else { $GUIDs[$us] = $GUID | Select-Object DistinguishedName,ExternalDirectoryObjectId }
        }
        if (!$GUIDs -or ($GUIDs.Count -eq 0)) { Write-Host "ERROR: No matching users found for ""$Identity"", check the parameter values." -ForegroundColor Red; return } #When in Process block, use return instead of continue
        Write-Verbose "The following list of users will be used: ""$($GUIDs.Values.DistinguishedName -join ", ")"""

        #Needed to handle array values for the Identity parameter
        foreach ($user in $GUIDs.GetEnumerator()) {
            Write-Verbose "Processing user ""$($user.Name)""..."
            Start-Sleep -Milliseconds 200 #Add some delay to avoid throttling...

            #Handle Exchange groups
            Write-Verbose "Obtaining group list for user ""$($user.Name)""..."
            if ($IncludeOffice365Groups) { $GroupTypes = @("GroupMailbox","MailUniversalDistributionGroup","MailUniversalSecurityGroup") }
            else { $GroupTypes = @("MailUniversalDistributionGroup","MailUniversalSecurityGroup") }
            $Groups = Get-EXORecipient -Filter "Members -eq '$($user.Value.DistinguishedName)'" -RecipientTypeDetails $GroupTypes -ErrorAction SilentlyContinue -Verbose:$false | Select-Object DisplayName,ExternalDirectoryObjectId,RecipientTypeDetails

            if (!$Groups) { Write-Verbose "No matching groups found for ""$($user.Name)"", skipping..." }
            else { Write-Verbose "User ""$($user.Name)"" is a member of $(($Groups | measure).count) group(s)." }

            #cycle over each Group
            foreach ($Group in $Groups) {
                Write-Verbose "Removing user ""$($user.Name)"" from group ""$($Group.DisplayName)"""
                #handle Microsoft 365 Groups
                if ($Group.RecipientTypeDetails -eq "GroupMailbox") {
                    try {
                        Write-Verbose "Removing user ""$($user.Name)"" from Microsoft 365 Group ""$($Group.DisplayName)"" ..."
                        Remove-UnifiedGroupLinks -Identity $Group.ExternalDirectoryObjectId -Links $user.Value.DistinguishedName -LinkType Member -Confirm:$false -WhatIf:$WhatIfPreference -ErrorAction Stop
                        $outtemp = New-Object psobject -Property ([ordered]@{"User" = $user.Name;"Group" = $Group.ExternalDirectoryObjectId;"GroupName" = $Group.DisplayName})
                        $out += $outtemp; if (!$Quiet -and !$WhatIfPreference) { $outtemp } #Write output to the console unless the -Quiet parameter is used
                    }
                    catch [System.Exception] {
                        #Some exceptions return the same category.reason RecipientTaskException. Using "exception" string match instead
                        if ($_.Exception.Message -match "ManagementObjectNotFoundException") { Write-Host "ERROR: The specified object was not found, this should not happen..." -ForegroundColor Red }
                        elseif ($_.Exception.Message -match "ADNoSuchObjectException|Couldn't find object") { Write-Host "ERROR: User object ""$($user.Name)"" not found, this should not happen..." -ForegroundColor Red }
                        elseif ($_.Exception.Message -match "DynamicGroupMembershipChangeDeniedException|Membership for this group is managed automatically") { Write-Host "ERROR: Group ""$($Group.DisplayName)"" uses dynamic membership, adjust the membership filter instead..." -ForegroundColor Red }
                        elseif ($_.Exception.Message -match "GroupOwnersCannotBeRemovedException|Only Members who are not owners") { Write-Host "ERROR: User object ""$($user.Name)"" is Owner of the ""$($Group.DisplayName)"" group and cannot be removed..." -ForegroundColor Red }
                        elseif ($_.Exception.Message -match "MinGroupOwnersCriteriaBreachedException|the person you're removing is currently the only owner") { Write-Host "ERROR: User object ""$($user.Name)"" is the only Owner of the ""$($Group.DisplayName)"" group and cannot be removed..." -ForegroundColor Red }
                        #no error is thrown if trying to remove a user that is not a member
                        else {$_ | fl * -Force; continue} #catch-all for any unhandled errors
                    }
                    catch {$_ | fl * -Force; continue} #catch-all for any unhandled errors
                }
                #handle "regular" groups
                else {
                    try {
                        Write-Verbose "Removing user ""$($user.Name)"" from Distribution Group ""$($Group.DisplayName)"" ..."
                        Remove-DistributionGroupMember -Identity $Group.ExternalDirectoryObjectId -Member $user.Value.DistinguishedName -BypassSecurityGroupManagerCheck -Confirm:$false -WhatIf:$WhatIfPreference -ErrorAction Stop
                        $outtemp = New-Object psobject -Property ([ordered]@{"User" = $user.Name;"Group" = $Group.ExternalDirectoryObjectId;"GroupName" = $Group.DisplayName})
                        $out += $outtemp; if (!$Quiet -and !$WhatIfPreference) { $outtemp } #Write output to the console unless the -Quiet parameter is used
                    }
                    catch [System.Exception] {
                        if ($_.Exception.Message -match "ManagementObjectNotFoundException") { Write-Host "ERROR: The specified object was not found, this should not happen..." -ForegroundColor Red }
                        elseif ($_.Exception.Message -match "MemberNotFoundException") { Write-Host "ERROR: User ""$($user.Name)"" is not a member of the ""$($Group.DisplayName)"" group..." -ForegroundColor Red }
                        else {$_ | fl * -Force; continue} #catch-all for any unhandled errors
                    }
                    catch {$_ | fl * -Force; continue} #catch-all for any unhandled errors
                }
            }

            #Handle Azure AD security groups
            if ($IncludeAADSecurityGroups -and $user.value.ExternalDirectoryObjectId) { #Some Exchange recipients will have empty ExternalDirectoryObjectId value, skip them
                Write-Verbose "Obtaining security group list for user ""$($user.Name)""..."
                $GroupsAD = Get-MgUserMemberOf -UserId $($user.value.ExternalDirectoryObjectId) -All -Filter {securityEnabled eq true and mailEnabled eq false} -ConsistencyLevel eventual -CountVariable count -Property id,displayName,mailEnabled,securityEnabled,membershipRule,mail,isAssignableToRole,groupTypes

                if (!$GroupsAD) { Write-Verbose "No matching security groups found for ""$($user.Name)"", skipping..." }
                else { Write-Verbose "User ""$($user.Name)"" is a member of $(($GroupsAD | measure).count) Azure AD security group(s)." }

                #cycle over each Group
                foreach ($groupAD in $GroupsAD) {
                    #skip groups with dynamic membership
                    if ($groupAD.AdditionalProperties.groupTypes -eq "DynamicMembership") { Write-Verbose "Skipping group ""$($groupAd.AdditionalProperties.displayName)"" as it uses dynamic membership. To remove the user, adjust the membership filter instead."; continue }

                    try {
                        Write-Verbose "Removing user ""$($user.Name)"" from group ""$($groupAD.AdditionalProperties.displayName)""..."
                        Remove-MgGroupMemberByRef -GroupId $groupAD.id -DirectoryObjectId $user.Value.ExternalDirectoryObjectId -ErrorAction Stop -Confirm:$false -WhatIf:$WhatIfPreference
                        $outtemp = New-Object psobject -Property ([ordered]@{"User" = $user.Name;"Group" = $groupAD.id;"GroupName" = $groupAD.AdditionalProperties.displayName})
                        $out += $outtemp; if (!$Quiet -and !$WhatIfPreference) { $outtemp } #Write output to the console unless the -Quiet parameter is used
                    }
                    #catch [Microsoft.Graph.PowerShell.Runtime.RestException`1] { #stupid module cannot even throw a proper error...
                    catch {
                        if ($_.Exception.Message -match "Insufficient privileges to complete the operation") { Write-Host "ERROR: You cannot remove members of the ""$($groupAD.AdditionalProperties.displayName)"" Dynamic group, adjust the membership filter instead..." -ForegroundColor Red }
                        elseif ($_.Exception.Message -match "Invalid object identifier") { Write-Host "ERROR: Group ""$($groupAD.AdditionalProperties.displayName)"" not found, this should not happen..." -ForegroundColor Red }
                        elseif ($_.Exception.Message -match "Unsupported referenced-object resource identifier") { Write-Host "ERROR: User ""$($user.Name)"" not found, this should not happen..." -ForegroundColor Red }
                        elseif ($_.Exception.Message -match "does not exist or one of its queried reference-property") { Write-Host "ERROR: Either the userID or GroupID does not exist, or the user is not a member of the group. This should not happen..." -ForegroundColor Red }
                        else {$_ | fl * -Force; continue} #catch-all for any unhandled errors
                    }
            }}
        }}
    End {
        if ($out) {
            Write-Verbose "Exporting results to the CSV file..."
            if (!$WhatIfPreference) { $out | Export-Csv -Path "$((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss'))_UserRemovedFromGroups.csv" -NoTypeInformation -Encoding UTF8 -UseCulture }
            if (!$Quiet -and !$WhatIfPreference) { return $out | Out-Default }  #Write output to the console unless the -Quiet parameter is used
        }
        else { Write-Verbose "Output is empty, skipping the export to CSV file..." }
        Write-Verbose "Finish..."
    }
}

#Invoke the Remove-MailboxFolderPermissionsRecursive function and pass the command line parameters. Make sure the output is stored in a variable for reuse, even if not specified in the input!
if ($PSBoundParameters.Count -ne 0) { Remove-UserFromAllGroups @PSBoundParameters }
else { Write-Host "INFO: The script was run without parameters, consider dot-sourcing it instead." -ForegroundColor Cyan ; return }
