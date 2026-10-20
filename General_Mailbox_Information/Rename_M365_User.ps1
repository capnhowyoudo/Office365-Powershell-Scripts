<#
.SYNOPSIS
    Renames a Microsoft 365 user and changes their sign-in / primary email address.

.DESCRIPTION
    - Updates the Entra ID user: display name, first/last name, mail nickname, UPN
    - Updates the mailbox: display name, alias, name, primary SMTP, Teams/SIP address
    - The old email address is left on the mailbox as a secondary alias
    - Stops if the account is synced from on-premises AD (see the AD section at the bottom)

.PARAMETER OldAddress
    Current sign-in / primary email address (e.g. jsmith@contoso.com)

.PARAMETER NewAddress
    New sign-in / primary email address (e.g. jdoe@contoso.com)

.PARAMETER FirstName
    New first name

.PARAMETER LastName
    New last name

.PARAMETER DisplayName
    Optional. Defaults to "FirstName LastName".

.EXAMPLE
    .\Rename_M365_User.ps1 -OldAddress jsmith@contoso.com -NewAddress jdoe@contoso.com -FirstName Jane -LastName Doe

.NOTES
    Requires: Microsoft.Graph and ExchangeOnlineManagement modules
      Install-Module Microsoft.Graph -Scope CurrentUser
      Install-Module ExchangeOnlineManagement -Scope CurrentUser
    Run as a Global Admin, or User Admin + Exchange Admin.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[^@\s]+@[^@\s]+\.[^@\s]+$')]
    [string]$OldAddress,

    [Parameter(Mandatory)][ValidatePattern('^[^@\s]+@[^@\s]+\.[^@\s]+$')]
    [string]$NewAddress,

    [Parameter(Mandatory)][string]$FirstName,
    [Parameter(Mandatory)][string]$LastName,

    [string]$DisplayName = "$FirstName $LastName"
)

$ErrorActionPreference = "Stop"
$Alias = $NewAddress.Split("@")[0]

# --- Connect ---------------------------------------------------------------
Connect-MgGraph -Scopes "User.ReadWrite.All" -NoWelcome
Connect-ExchangeOnline -ShowBanner:$false

# --- Find the user ---------------------------------------------------------
$user = Get-MgUser -UserId $OldAddress -Property Id,DisplayName,UserPrincipalName,OnPremisesSyncEnabled
Write-Host "Found: $($user.DisplayName) <$($user.UserPrincipalName)>"

if ($user.OnPremisesSyncEnabled) {
    Write-Warning "This account is synced from on-premises Active Directory."
    Write-Warning "Make the change in AD (see commented section at bottom), then run a delta sync."
    return
}

# Make sure the new address isn't already taken
if (Get-MgUser -Filter "userPrincipalName eq '$NewAddress'" -ErrorAction SilentlyContinue) {
    throw "$NewAddress is already in use by another account."
}

# --- Update the Entra ID (Azure AD) user -----------------------------------
Update-MgUser -UserId $user.Id `
    -DisplayName $DisplayName `
    -GivenName $FirstName `
    -Surname $LastName `
    -MailNickname $Alias `
    -UserPrincipalName $NewAddress
Write-Host "Updated name and sign-in (UPN) to $NewAddress"

# --- Update the mailbox ----------------------------------------------------
Start-Sleep -Seconds 30   # allow Exchange to pick up the UPN change
# Note: the old address ($OldAddress) is intentionally left on the mailbox as a secondary alias.

$id = $NewAddress

# Display name, alias and mailbox name
Set-Mailbox -Identity $id -DisplayName $DisplayName -Alias $Alias -Name $DisplayName

# Make sure the new primary SMTP address is set
Set-Mailbox -Identity $id -WindowsEmailAddress $NewAddress

# Update the Teams/Skype (SIP) address
Set-Mailbox -Identity $id -EmailAddresses @{ Remove = "SIP:$OldAddress"; Add = "SIP:$NewAddress" }

# --- Verify ----------------------------------------------------------------
Get-Mailbox -Identity $id | Format-List DisplayName, Alias, PrimarySmtpAddress, EmailAddresses
Get-MgUser -UserId $id -Property DisplayName,GivenName,Surname,UserPrincipalName,MailNickname |
    Format-List DisplayName, GivenName, Surname, UserPrincipalName, MailNickname

Disconnect-ExchangeOnline -Confirm:$false
Disconnect-MgGraph | Out-Null

<# ---------------------------------------------------------------------------
 ON-PREMISES ACTIVE DIRECTORY VERSION (use instead if the account is synced)
 Set the variables first, then run on a machine with the ActiveDirectory module.

 $OldAddress = "jsmith@contoso.com"
 $NewAddress = "jdoe@contoso.com"
 $FirstName  = "Jane"
 $LastName   = "Doe"
 $DisplayName = "$FirstName $LastName"
 $Alias = $NewAddress.Split("@")[0]

 $sam = (Get-ADUser -Filter "UserPrincipalName -eq '$OldAddress'").SamAccountName
 Set-ADUser $sam -GivenName $FirstName -Surname $LastName -DisplayName $DisplayName `
     -UserPrincipalName $NewAddress -EmailAddress $NewAddress `
     -SamAccountName $Alias -Replace @{
         mailNickname   = $Alias
         proxyAddresses = @("SMTP:$NewAddress","smtp:$OldAddress")
     }
 Get-ADUser $Alias | Rename-ADObject -NewName $DisplayName
 Start-ADSyncSyncCycle -PolicyType Delta   # run on the Entra Connect server
---------------------------------------------------------------------------- #>
