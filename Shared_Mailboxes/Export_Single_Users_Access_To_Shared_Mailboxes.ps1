<#
.SYNOPSIS
    Lists every shared mailbox a user has access to in Microsoft 365 (Exchange Online),
    and whether each shared mailbox is licensed or unlicensed.

.DESCRIPTION
    Checks, per shared mailbox:
      - Full Access   (direct, or via a mail-enabled group the user belongs to)
      - Send As       (direct, or via group)
      - Send on Behalf(direct, or via group)
    Then looks up the shared mailbox's assigned licenses via Microsoft Graph.

    Group-based access is resolved for groups that Exchange can see the user in
    (distribution lists, mail-enabled security groups, M365 groups, dynamic DLs excluded).

.PARAMETER UserPrincipalName
    UPN / primary email of the user to check.

.PARAMETER ExportPath
    Optional CSV path for the results.

.EXAMPLE
    .\Export_Single_Users_Access_To_Shared_Mailboxes.ps1 -UserPrincipalName jdoe@contoso.com -ExportPath C:\Temp\jdoe-shared.csv

.NOTES
    Modules:  ExchangeOnlineManagement, Microsoft.Graph.Users
    Install:  Install-Module ExchangeOnlineManagement, Microsoft.Graph.Users -Scope CurrentUser
    Rights:   Exchange: View-Only Recipients / View-Only Configuration (or higher)
              Graph:    User.Read.All
    Runtime:  Per-mailbox permission lookups are slow in large tenants (a few hundred
              mailboxes can take several minutes).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [string]$ExportPath
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- Connect
# Connect Graph FIRST. The Graph and Exchange modules ship different versions of
# Microsoft.Identity.Client; whichever loads first wins, and Graph breaks
# ("Method not found ... WithLogging") if Exchange loaded first. Use a fresh PowerShell window.
$graphConnected = $false
try {
    if (-not (Get-MgContext)) { Connect-MgGraph -Scopes 'User.Read.All' -NoWelcome -ErrorAction Stop }
    $graphConnected = $true
}
catch {
    Write-Warning "Could not connect to Microsoft Graph. License status will show 'Unknown'. $($_.Exception.Message)"
}

if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Connected' })) {
    Connect-ExchangeOnline -ShowBanner:$false
}

# ---------------------------------------------------------------- Resolve user + their groups
$user = Get-Recipient -Identity $UserPrincipalName
$userDN = $user.DistinguishedName

# Identities that can appear as a trustee for this user
$identities = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($v in @($user.PrimarySmtpAddress, $UserPrincipalName, $user.Name, $user.Alias, $user.DisplayName)) {
    if ($v) { [void]$identities.Add("$v") }
}

# Groups the user is a direct member of (mail-enabled groups)
$groups = Get-Recipient -Filter "Members -eq '$userDN'" -RecipientTypeDetails `
    MailUniversalDistributionGroup, MailUniversalSecurityGroup, GroupMailbox -ResultSize Unlimited `
    -ErrorAction SilentlyContinue

$groupIdentities = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($g in $groups) {
    foreach ($v in @($g.PrimarySmtpAddress, $g.Name, $g.Alias, $g.DisplayName)) {
        if ($v) { [void]$groupIdentities.Add("$v") }
    }
}

Write-Host "User: $($user.DisplayName) <$($user.PrimarySmtpAddress)>  |  Mail-enabled groups found: $(@($groups).Count)" -ForegroundColor Cyan

function Test-Trustee {
    param([string]$Trustee)
    if (-not $Trustee) { return $null }
    $t = $Trustee -replace '^.*\\', ''          # strip DOMAIN\ prefix
    if ($identities.Contains($Trustee) -or $identities.Contains($t)) { return 'Direct' }
    if ($groupIdentities.Contains($Trustee) -or $groupIdentities.Contains($t)) { return 'Group' }
    return $null
}

# ---------------------------------------------------------------- Scan shared mailboxes
$shared = Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited `
    -Properties GrantSendOnBehalfTo, ExternalDirectoryObjectId, ExchangeGuid, PrimarySmtpAddress, DisplayName

Write-Host "Shared mailboxes in tenant: $(@($shared).Count). Scanning..." -ForegroundColor Cyan

$results = [System.Collections.Generic.List[object]]::new()
$i = 0

foreach ($mbx in $shared) {
    $i++
    Write-Progress -Activity 'Scanning shared mailboxes' -Status "$i of $(@($shared).Count): $($mbx.PrimarySmtpAddress)" `
        -PercentComplete (($i / @($shared).Count) * 100)

    # Identity used for permission lookups (ExchangeGuid is not returned by default)
    $mbxId = if ($mbx.ExternalDirectoryObjectId) { "$($mbx.ExternalDirectoryObjectId)" }
             elseif ($mbx.ExchangeGuid)          { "$($mbx.ExchangeGuid)" }
             else                                { "$($mbx.PrimarySmtpAddress)" }

    $access = [System.Collections.Generic.List[string]]::new()
    $via    = [System.Collections.Generic.HashSet[string]]::new()

    # Full Access
    try {
        Get-EXOMailboxPermission -Identity $mbxId -ErrorAction Stop |
            Where-Object { -not $_.IsInherited -and -not $_.Deny -and $_.AccessRights -contains 'FullAccess' } |
            ForEach-Object {
                $m = Test-Trustee $_.User
                if ($m) { if (-not $access.Contains('FullAccess')) { $access.Add('FullAccess') }; [void]$via.Add($m) }
            }
    } catch { Write-Warning "FullAccess check failed on $($mbx.PrimarySmtpAddress): $($_.Exception.Message)" }

    # Send As
    try {
        Get-EXORecipientPermission -Identity $mbxId -ErrorAction Stop |
            Where-Object { $_.AccessRights -contains 'SendAs' -and $_.AccessControlType -eq 'Allow' } |
            ForEach-Object {
                $m = Test-Trustee $_.Trustee
                if ($m) { if (-not $access.Contains('SendAs')) { $access.Add('SendAs') }; [void]$via.Add($m) }
            }
    } catch { Write-Warning "SendAs check failed on $($mbx.PrimarySmtpAddress): $($_.Exception.Message)" }

    # Send on Behalf
    foreach ($sob in @($mbx.GrantSendOnBehalfTo)) {
        $m = Test-Trustee "$sob"
        if ($m) { if (-not $access.Contains('SendOnBehalf')) { $access.Add('SendOnBehalf') }; [void]$via.Add($m) }
    }

    if ($access.Count -eq 0) { continue }

    # License status
    $licenseStatus = 'Unknown'
    $skus = ''
    if ($graphConnected) {
        try {
            $mgUser = Get-MgUser -UserId $mbx.ExternalDirectoryObjectId -Property AssignedLicenses -ErrorAction Stop
            if (@($mgUser.AssignedLicenses).Count -gt 0) {
                $licenseStatus = 'Licensed'
                $skus = ($mgUser.AssignedLicenses.SkuId -join '; ')
            } else {
                $licenseStatus = 'Unlicensed'
            }
        } catch { $licenseStatus = 'Unknown' }
    }

    $results.Add([pscustomobject]@{
        SharedMailbox = $mbx.DisplayName
        EmailAddress  = $mbx.PrimarySmtpAddress
        Permissions   = ($access -join ', ')
        AccessVia     = ($via -join ', ')
        License       = $licenseStatus
        LicenseSkuIds = $skus
    })
}

Write-Progress -Activity 'Scanning shared mailboxes' -Completed

# ---------------------------------------------------------------- Output
$results = $results | Sort-Object License, SharedMailbox
$results | Format-Table SharedMailbox, EmailAddress, Permissions, AccessVia, License -AutoSize

Write-Host ("`nTotal: {0}  |  Licensed: {1}  |  Unlicensed: {2}  |  Unknown: {3}" -f `
    @($results).Count,
    @($results | Where-Object License -eq 'Licensed').Count,
    @($results | Where-Object License -eq 'Unlicensed').Count,
    @($results | Where-Object License -eq 'Unknown').Count) -ForegroundColor Green

if ($ExportPath) {
    $results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Exported to $ExportPath" -ForegroundColor Green
}
