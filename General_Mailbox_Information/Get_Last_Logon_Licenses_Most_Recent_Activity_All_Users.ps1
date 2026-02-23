<#
.SYNOPSIS
    Generates a CSV report of licensed Microsoft 365 users and their last mailbox activity.

.DESCRIPTION
    This script connects to Microsoft Graph to retrieve user license information and 
    Exchange Online to retrieve mailbox statistics. It is specifically designed for 
    tenants without Entra ID Premium licenses, using mailbox activity as a proxy 
    for the last sign-in date.

.NOTES
    Prerequisites:
    1. Microsoft Graph PowerShell SDK installed.
    2. Exchange Online Management module installed.
    3. Permissions: User.Read.All and Organization.Read.All for Graph.
    4. Execution: Must be run with permissions to write to C:\temp.

    Property Definitions:
    - LastLogonTime: This property indicates the last time a user logged into the mailbox.
    - LastUserActionTime: This property indicates the last time a user performed an action within the mailbox (e.g., sending, receiving, deleting an email).
#>

# 1. Connect to both services
Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All"
Connect-ExchangeOnline

$Path = "C:\temp"
if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path }

# 2. Map License Names
$SkuTable = @{}
Get-MgSubscribedSku | ForEach-Object { $SkuTable[$_.SkuId.ToString()] = $_.SkuPartNumber }

Write-Host "Gathering User, License, and Mailbox data..." -ForegroundColor Cyan

# 3. Get all licensed users from Graph
$LicensedUsers = Get-MgUser -All -Property "DisplayName", "UserPrincipalName", "AssignedLicenses" | 
                 Where-Object { $_.AssignedLicenses.Count -gt 0 }

$Report = ForEach ($User in $LicensedUsers) {
    # Get Mailbox Statistics for this user (Plan B for last sign-in)
    try {
        $Stats = Get-MailboxStatistics -Identity $User.UserPrincipalName -ErrorAction SilentlyContinue
    } catch {
        $Stats = $null
    }

    $ReadableLicenses = $User.AssignedLicenses.SkuId | ForEach-Object { 
        if ($SkuTable[$_.ToString()]) { $SkuTable[$_.ToString()] } else { $_ } 
    }

    [PSCustomObject]@{
        DisplayName           = $User.DisplayName
        UserPrincipalName     = $User.UserPrincipalName
        Licenses              = $ReadableLicenses -join "; "
        LastMailboxLogon      = $Stats.LastLogonTime
        LastUserAction        = $Stats.LastUserActionTime
    }
}

# 4. Export to CSV
$FileName = "$Path\M365_Mailbox_Activity_Report_$(Get-Date -Format 'yyyyMMdd').csv"
$Report | Export-Csv -Path $FileName -NoTypeInformation -Encoding utf8

Write-Host "Success! Report saved to $FileName" -ForegroundColor Green
