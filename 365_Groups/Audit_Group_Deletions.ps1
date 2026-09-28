<#
.SYNOPSIS
    Searches for group deletions (via Microsoft Graph's directory audit log, which reliably
    includes the group's real display name) and site deletions (via the M365 unified audit
    log), so you can see exactly which account -- a real person, or a system/service account
    -- deleted each one.

.NOTES
    Requires the ExchangeOnlineManagement module (for site deletions) AND the
    Microsoft.Graph.Reports module (for group deletions -- see below for why).
    Install once, if needed:
        Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
        Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force

    Works fine on Windows PowerShell 5.1 - no PS7 requirement here.

    IMPORTANT: Run this in a fresh PowerShell window that has not loaded PnP.PowerShell
    in this session, to avoid an unrelated assembly-conflict error (PnP.PowerShell bundles
    an old Microsoft.Graph.Core that breaks Microsoft.Graph cmdlets). Exchange Online and
    Microsoft.Graph together in the same session are fine -- it's specifically PnP that
    causes the conflict.

    WHY TWO DIFFERENT LOG SOURCES: Search-UnifiedAuditLog's raw AuditData for
    "Delete group." (RecordType AzureActiveDirectory) does NOT reliably expose the group's
    display name -- only its GUID (shown as e.g. "Group_1a2947b7-..."). The modern
    Microsoft Graph directory audit log (the same one the Entra ID admin center's own
    audit log UI uses) exposes the display name directly via TargetResources[].DisplayName,
    so that's used here instead for group deletions. Site deletions ("SiteDeleted") ARE
    reliably exposed via Search-UnifiedAuditLog, so that part is unchanged.

    Permissions needed (consented on first Connect-MgGraph run):
      - AuditLog.Read.All
      - Directory.Read.All

    You need Compliance Administrator, Global Admin, or Audit Logs permission for both.

    EXAMPLES:
        # Default: search the last 30 days, no name filter
        .\Get-GroupDeletionAudit.ps1

        # Search a shorter window (e.g. just today/yesterday)
        .\Get-GroupDeletionAudit.ps1 -DaysBack 2

        # Search the full 30-day retention window (the max Entra ID keeps for this log)
        .\Get-GroupDeletionAudit.ps1 -DaysBack 30

        # Narrow results to only groups/sites whose name contains "Bacardi"
        .\Get-GroupDeletionAudit.ps1 -DaysBack 30 -NameFilter "Bacardi"

        # Combine both: last 7 days, only names containing "Designers"
        .\Get-GroupDeletionAudit.ps1 -DaysBack 7 -NameFilter "Designers"
#>

param(
    # How many days back to search (Entra ID audit log retention is 30 days by default,
    # M365 unified audit log up to 90 days / 1 year with extended licensing)
    [int]$DaysBack = 30,

    # Optional: only show results whose group/site name contains this text (partial match)
    [string]$NameFilter = ""
)

Import-Module ExchangeOnlineManagement -ErrorAction Stop
Import-Module Microsoft.Graph.Reports -ErrorAction Stop

Write-Host "Connecting to Exchange Online (for site deletion audit)..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Connecting to Microsoft Graph (for group deletion audit)..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "AuditLog.Read.All", "Directory.Read.All" -NoWelcome

$startDate = (Get-Date).AddDays(-$DaysBack)
$endDate   = Get-Date

# --- Group deletions (via Microsoft Graph directory audit log -- has real display names) ---
Write-Host "`nSearching for 'Delete group' events (last $DaysBack days)..." -ForegroundColor Cyan

# NOTE: Even a single-clause $filter on activityDisplayName was silently returning zero rows
# for this tenant -- Graph's directory audit log filtering can be unreliable depending on
# tenant/API version. To guarantee we don't silently miss real events, this pulls ALL
# directory audit records in range (bounded automatically by the log's own retention window)
# and does the matching entirely in PowerShell instead of relying on server-side $filter.
$allAudits = @()
$groupCallFailed = $false
try {
    $allAudits = Get-MgAuditLogDirectoryAudit -All -ErrorAction Stop
    Write-Host "Retrieved $($allAudits.Count) total directory audit record(s) from the log (all activity types, full retention window)." -ForegroundColor DarkCyan
}
catch {
    $groupCallFailed = $true
    Write-Host "FAILED to query the directory audit log: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "If this mentions AzureIdentityAccessTokenProvider or an assembly load error, close this window and re-run in a fresh one with no PnP.PowerShell loaded." -ForegroundColor Red
}

$groupRaw = @()
if (-not $groupCallFailed) {
    $groupRaw = $allAudits | Where-Object {
        $_.ActivityDisplayName -eq "Delete group" -and $_.ActivityDateTime -ge $startDate
    }
    Write-Host "Of those, $($groupRaw.Count) match 'Delete group' within the last $DaysBack days." -ForegroundColor DarkCyan
}

$groupReport = @()
$groupReportFull = @()
if ($groupRaw -and -not $groupCallFailed) {
    $groupReport = $groupRaw | ForEach-Object {
        $target = $_.TargetResources | Select-Object -First 1
        [PSCustomObject]@{
            DeletedOn = $_.ActivityDateTime
            DeletedBy = if ($_.InitiatedBy.App) { $_.InitiatedBy.App.DisplayName } else { $_.InitiatedBy.User.UserPrincipalName }
            GroupName = $target.DisplayName
            GroupId   = $target.Id
            ClientIP  = $_.InitiatedBy.User.IpAddress
            Result    = $_.Result
        }
    } | Sort-Object DeletedOn -Descending

    if ($NameFilter) {
        $groupReport = $groupReport | Where-Object { $_.GroupName -like "*$NameFilter*" }
    }

    Write-Host "`n=== Group deletions ===" -ForegroundColor Cyan
    $groupReport | Format-Table -AutoSize

    # Build a row matching the exact column layout of a native Purview audit log export
    # (Date (UTC), CorrelationId, Service, Category, Activity, ActorDisplayName,
    # Target1/2/3 with up to 5 ModifiedProperties each, AdditionalDetail1-6, etc.)
    $groupReportFull = $groupRaw | ForEach-Object {
        $row = [ordered]@{
            "Date (UTC)"              = $_.ActivityDateTime
            "CorrelationId"           = $_.CorrelationId
            "Service"                 = $_.LoggedByService
            "Category"                = $_.Category
            "Activity"                = $_.ActivityDisplayName
            "Result"                  = $_.Result
            "ResultReason"            = $_.ResultReason
            "User Agent"              = ""
            "ActorType"               = if ($_.InitiatedBy.User) { "User" } else { "App" }
            "ActorDisplayName"        = $_.InitiatedBy.User.DisplayName
            "ActorObjectId"           = $_.InitiatedBy.User.Id
            "ActorUserPrincipalName"  = $_.InitiatedBy.User.UserPrincipalName
            "IPAddress"               = $_.InitiatedBy.User.IpAddress
            "ActorHomeTenantId"       = $_.InitiatedBy.User.HomeTenantId
            "ActorHomeTenantName"     = $_.InitiatedBy.User.HomeTenantName
            "ActorServicePrincipalId"   = $_.InitiatedBy.App.ServicePrincipalId
            "ActorServicePrincipalName" = $_.InitiatedBy.App.ServicePrincipalName
        }

        # Up to 3 targets, each with up to 5 modified properties -- same shape as the native export
        for ($t = 1; $t -le 3; $t++) {
            $target = $_.TargetResources | Select-Object -Skip ($t - 1) -First 1
            $prefix = "Target$t"
            $row["$prefix" + "Type"]              = $target.Type
            $row["$prefix" + "DisplayName"]       = $target.DisplayName
            $row["$prefix" + "ObjectId"]          = $target.Id
            $row["$prefix" + "UserPrincipalName"] = $target.UserPrincipalName

            for ($p = 1; $p -le 5; $p++) {
                $modProp = $target.ModifiedProperties | Select-Object -Skip ($p - 1) -First 1
                $row["$prefix" + "ModifiedProperty$p" + "Name"]     = $modProp.DisplayName
                $row["$prefix" + "ModifiedProperty$p" + "OldValue"] = $modProp.OldValue
                $row["$prefix" + "ModifiedProperty$p" + "NewValue"] = $modProp.NewValue
            }
        }

        # Up to 6 additional details as Key/Value pairs
        for ($a = 1; $a -le 6; $a++) {
            $detail = $_.AdditionalDetails | Select-Object -Skip ($a - 1) -First 1
            $row["AdditionalDetail$a" + "Key"]   = $detail.Key
            $row["AdditionalDetail$a" + "Value"] = $detail.Value
        }

        [PSCustomObject]$row
    }

    if ($NameFilter) {
        $groupReportFull = $groupReportFull | Where-Object { $_.Target1DisplayName -like "*$NameFilter*" }
    }
}
elseif (-not $groupCallFailed) {
    Write-Host "No 'Delete group' events found in this window." -ForegroundColor Yellow
}

# --- Site deletions ---
Write-Host "`nSearching for 'SiteDeleted' events in the same window..." -ForegroundColor Cyan

$siteRaw = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations "SiteDeleted" -ResultSize 5000

$siteReport = @()
if ($siteRaw) {
    $siteReport = $siteRaw | ForEach-Object {
        $data = $_.AuditData | ConvertFrom-Json
        [PSCustomObject]@{
            DeletedOn = $data.CreationTime
            DeletedBy = $data.UserId
            SiteUrl   = $data.SiteUrl
            ClientIP  = $data.ClientIP
            Workload  = $data.Workload
        }
    } | Sort-Object DeletedOn -Descending

    if ($NameFilter) {
        $siteReport = $siteReport | Where-Object { $_.SiteUrl -like "*$NameFilter*" }
    }

    Write-Host "`n=== Site deletions ===" -ForegroundColor Cyan
    $siteReport | Format-Table -AutoSize
}
else {
    Write-Host "No 'SiteDeleted' events found in this window." -ForegroundColor Yellow
}

# --- Export both reports to C:\temp ---
$exportDir = "C:\temp"
if (-not (Test-Path $exportDir)) {
    New-Item -Path $exportDir -ItemType Directory -Force | Out-Null
}
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

if ($groupReportFull.Count -gt 0) {
    $groupExportPath = Join-Path $exportDir "GroupDeletionAudit_$timestamp.csv"
    $groupReportFull | Export-Csv -Path $groupExportPath -NoTypeInformation
    Write-Host "`nExported group deletion report (Purview-style format) to $groupExportPath" -ForegroundColor Green
}

if ($siteReport.Count -gt 0) {
    $siteExportPath = Join-Path $exportDir "SiteDeletionAudit_$timestamp.csv"
    $siteReport | Export-Csv -Path $siteExportPath -NoTypeInformation
    Write-Host "Exported site deletion report to $siteExportPath" -ForegroundColor Green
}

Disconnect-ExchangeOnline -Confirm:$false
Disconnect-MgGraph | Out-Null
