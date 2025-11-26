<#
.SYNOPSIS
Exports Microsoft 365 users' per-user MFA status report to a CSV file.

.DESCRIPTION
This script connects to Microsoft Graph (Beta), retrieves all users, and gathers detailed authentication 
method information for each user. It evaluates per-user MFA status, filters users based on optional parameters 
(e.g., MFA enabled/disabled, licensed users only, sign-in allowed users), and exports the results to a CSV file. 
The output CSV file is created in the path C:\Temp with a timestamped name. 
It supports certificate-based authentication, MFA-enabled accounts, and is scheduler-friendly.

.NOTES
Requires Microsoft Graph Beta PowerShell module.
The output CSV file is created in C:\Temp with a timestamped name.

MFA Status in Office 365 Admin Console: This setting controls whether or not MFA is enabled for a specific user. If MFA Status is set to “Disabled” for a user, they will not be prompted for MFA when they sign in. 
However, if MFA is enabled at the tenant level (via Security Defaults or Conditional Access policies), the user may still be prompted for MFA.

MS Authenticator in Azure AD Auth Methods: This setting controls whether or not users can use the Microsoft Authenticator app as a second factor for MFA. 
If MS Authenticator is set to “Disabled” in the policy, users will not be able to use the app even if MFA is required.

Security Defaults: Security Defaults is a pre-configured set of security settings in Azure AD that is designed to help protect organizations from common security threats. 
One of the settings in Security Defaults is to require MFA for all users. If Security Defaults is enabled, all users will be prompted for MFA when they sign in, regardless of the MFA Status setting in the Office 365 Admin Console.

It’s possible that Security Defaults is overriding the MFA Status setting in the Office 365 Admin Console, which could explain why users are being prompted for MFA even when their MFA Status is set to “Disabled”. 
To confirm whether Security Defaults is enabled, go to Azure Active Directory > Properties and look for the “Manage Security defaults” option.

Parameter Usage Examples:

1. -CreateSession
   Forces a new Microsoft Graph session.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -CreateSession

2. -MFAEnabledUsersOnly
   Exports only users with MFA enabled.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -MFAEnabledUsersOnly

3. -MFADisabledUsersOnly
   Exports only users with MFA disabled.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -MFADisabledUsersOnly

4. -MFAEnforcedUsersOnly
   Exports only users with MFA enforced.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -MFAEnforcedUsersOnly

5. -LicensedUsersOnly
   Exports only licensed users.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -LicensedUsersOnly

6. -SignInAllowedUsersOnly
   Exports only users who are allowed to sign in.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -SignInAllowedUsersOnly

7. -TenantId
   Specifies the tenant ID when using certificate-based authentication.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

8. -ClientId
   Specifies the application (client) ID for certificate-based authentication.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -ClientId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

9. -CertificateThumbprint
   Specifies the certificate thumbprint for certificate-based authentication.
   Example:
   .\Check_MFA_Status_All_Users.ps1 -CertificateThumbprint "ABCD1234EF567890..."

You can combine switches for more granular filtering:
Example: Export only MFA enabled licensed users:
.\Check_MFA_Status_All_Users.ps1 -MFAEnabledUsersOnly -LicensedUsersOnly
#>

#Connect to Microsoft Graph (Beta) with necessary permissions or certificate
Connect_MgGraph

#Set output file path
$ExportCSV="C:\Temp\MfaStatusReport_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"

#Get all users and their MFA/authentication details
Get-MgBetaUser -All | ForEach-Object {
    #Processed user count increment
    $ProcessedUserCount++
    
    #User properties
    $Name = $_.DisplayName
    $UPN = $_.UserPrincipalName
    $Department = $_.Department
    $UserId = $_.Id
    $SigninStatus = if ($_.AccountEnabled) { "Allowed" } else { "Blocked" }
    $LicenseStatus = if ($_.AssignedLicenses.Count -ne 0) { "Licensed" } else { "Unlicensed" }
    $Is3rdPartyAuthenticatorUsed = "False"
    $MFAPhone = "-"
    $MicrosoftAuthenticatorDevice = "-"
    
    #Progress display
    Write-Progress -Activity "`n     Processed users count: $ProcessedUserCount "`n"  Currently processing user: $Name"

    #Get MFA/authentication methods for user
    [array]$MFAData = Get-MgBetaUserAuthenticationMethod -UserId $UPN
    $AuthenticationMethod = @()
    $AdditionalDetails = @()

    foreach ($MFA in $MFAData) {
        Switch ($MFA.AdditionalProperties["@odata.type"]) {
            "#microsoft.graph.passwordAuthenticationMethod" { $AuthMethod='PasswordAuthentication'; $AuthMethodDetails=$MFA.AdditionalProperties["displayName"] }
            "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" { $AuthMethod='AuthenticatorApp'; $AuthMethodDetails=$MFA.AdditionalProperties["displayName"]; $MicrosoftAuthenticatorDevice=$MFA.AdditionalProperties["displayName"] }
            "#microsoft.graph.phoneAuthenticationMethod" { $AuthMethod='PhoneAuthentication'; $AuthMethodDetails=$MFA.AdditionalProperties["phoneType","phoneNumber"] -join ' '; $MFAPhone=$MFA.AdditionalProperties["phoneNumber"] }
            "#microsoft.graph.fido2AuthenticationMethod" { $AuthMethod='Passkeys(FIDO2)'; $AuthMethodDetails=$MFA.AdditionalProperties["model"] }
            "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" { $AuthMethod='WindowsHelloForBusiness'; $AuthMethodDetails=$MFA.AdditionalProperties["displayName"] }
            "#microsoft.graph.emailAuthenticationMethod" { $AuthMethod='EmailAuthentication'; $AuthMethodDetails=$MFA.AdditionalProperties["emailAddress"] }
            "microsoft.graph.temporaryAccessPassAuthenticationMethod" { $AuthMethod='TemporaryAccessPass'; $AuthMethodDetails='Access pass lifetime (minutes): ' + $MFA.AdditionalProperties["lifetimeInMinutes"] }
            "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod" { $AuthMethod='PasswordlessMSAuthenticator'; $AuthMethodDetails=$MFA.AdditionalProperties["displayName"] }
            "#microsoft.graph.softwareOathAuthenticationMethod" { $AuthMethod='SoftwareOath'; $Is3rdPartyAuthenticatorUsed="True" }
        }
        $AuthenticationMethod += $AuthMethod
        if ($AuthMethodDetails -ne $null) { $AdditionalDetails += "$AuthMethod : $AuthMethodDetails" }
    }

    #Remove duplicates
    $AuthenticationMethod = $AuthenticationMethod | Sort-Object | Get-Unique
    $AuthenticationMethods = $AuthenticationMethod -join ","
    $AdditionalDetail = $AdditionalDetails -join ", "
    $Print = 1

    #Retrieve per-user MFA status
    $MFAStatus = (Invoke-MgGraphRequest -Method GET -Uri "/beta/users/$UserId/authentication/requirements").perUserMfaState

    #Filter based on parameters
    if ($MFADisabledUsersOnly.IsPresent -and $MFAStatus -ne "disabled") { $Print = 0 }
    if ($MFAEnabledUsersOnly.IsPresent -and $MFAStatus -ne "enabled") { $Print = 0 }
    if ($MFAEnforcedUsersOnly.IsPresent -and $MFAStatus -ne "enforced") { $Print = 0 }
    if ($LicensedUsersOnly.IsPresent -and ($LicenseStatus -eq "Unlicensed")) { $Print = 0 }
    if ($SignInAllowedUsersOnly.IsPresent -and ($SigninStatus -eq "Blocked")) { $Print = 0 }

    if ($Print -eq 1) {
        $ExportCount++
        $Result=@{
            'Name'=$Name
            'UPN'=$UPN
            'Department'=$Department
            'License Status'=$LicenseStatus
            'SignIn Status'=$SigninStatus
            'Registered Authentication Methods'=$AuthenticationMethods
            'Per-user MFA Status'=$MFAStatus
            'MFA Phone'=$MFAPhone
            'Microsoft Authenticator Configured Device'=$MicrosoftAuthenticatorDevice
            'Is 3rd-Party Authenticator Used'=$Is3rdPartyAuthenticatorUsed
            'Additional Details'=$AdditionalDetail
        }
        $Results = New-Object PSObject -Property $Result
        $Results | Select-Object Name,UPN,'Per-user MFA Status',Department,'License Status','SignIn Status','Registered Authentication Methods','MFA Phone','Microsoft Authenticator Configured Device','Is 3rd-Party Authenticator Used','Additional Details' | Export-Csv -Path $ExportCSV -NoType -Append
    }
}

#Final output
if ((Test-Path -Path $ExportCSV) -eq "True") {
    Write-Host "`nThe exported report contains $ExportCount users."
    Write-Host "`nPer-user MFA status report available in: " -NoNewline -ForegroundColor Yellow; Write-Host $ExportCSV
} else {
    Write-Host "No users found."
}
