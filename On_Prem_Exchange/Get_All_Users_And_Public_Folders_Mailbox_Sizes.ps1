<#
.SYNOPSIS
    Reports current mailbox size vs. quota (max size) for all mailboxes on an on-premises
    Exchange Server organization.

.DESCRIPTION
    Runs against on-prem Exchange (Exchange Management Shell / EMS, or a machine with the
    Exchange management tools / remote PowerShell session loaded). For each mailbox it pulls:
      - Display Name / Alias
      - Database
      - Current mailbox size (TotalItemSize)
      - Item count
      - Effective quota (IssueWarningQuota / ProhibitSendQuota / ProhibitSendReceiveQuota)
      - Percent of ProhibitSendReceiveQuota used
      - Whether the mailbox uses the database default quota or a custom (per-mailbox) quota

    Optionally (-IncludePublicFolders) it also reports:
      - Public folder mailboxes (the mailboxes that host public folder content) - size vs. quota,
        same as regular mailboxes
      - Individual mail-enabled (and non-mail-enabled) public folders - size and item count,
        with the quota that applies to them (per-folder override or org-wide default)

.NOTES
    Run this from the Exchange Management Shell, or from a regular PowerShell window after
    connecting to Exchange via remote PowerShell:

        $Session = New-PSSession -ConfigurationName Microsoft.Exchange `
            -ConnectionUri http://<YourCASServer>/PowerShell/ -Authentication Kerberos
        Import-PSSession $Session

    Requires View-Only Organization Management (or higher) permissions.

.PARAMETER OrganizationalUnit
    Optional. Limit the mailbox report to mailboxes in a specific OU, e.g. "contoso.com/Users/Sales"

.PARAMETER ExportPath
    Optional. Path to export the mailbox CSV report to. Defaults to C:\temp\MailboxSizeReport.csv
    (the folder is created automatically if it doesn't exist).

.PARAMETER IncludePublicFolders
    Optional switch. When present, also reports on public folder mailboxes and individual
    public folders. Results are exported to C:\temp\PublicFolderMailboxSizeReport.csv and
    C:\temp\PublicFolderSizeReport.csv (paths configurable via -PFMailboxExportPath and
    -PFExportPath).

.PARAMETER PFMailboxExportPath
    Optional. Path to export the public folder *mailbox* CSV report to.
    Defaults to C:\temp\PublicFolderMailboxSizeReport.csv

.PARAMETER PFExportPath
    Optional. Path to export the individual public folder CSV report to.
    Defaults to C:\temp\PublicFolderSizeReport.csv

.EXAMPLE
    .Get_All_Users_And_Public_Folders_Mailbox_Sizes.ps1
    (exports to C:\temp\MailboxSizeReport.csv)

.EXAMPLE
    .\Get_All_Users_And_Public_Folders_Mailbox_Sizes.ps1 -ExportPath "C:\Reports\MailboxSizes.csv"

.EXAMPLE
    .\Get_All_Users_And_Public_Folders_Mailbox_Sizes.ps1 -OrganizationalUnit "contoso.com/Users/Sales" -ExportPath "C:\Reports\Sales.csv"

.EXAMPLE
    .\Get_All_Users_And_Public_Folders_Mailbox_Sizes.ps1 -IncludePublicFolders
    (also exports public folder mailbox and per-folder size reports to C:\temp)
#>

[CmdletBinding()]
param(
    [string]$OrganizationalUnit,
    [string]$ExportPath = "C:\temp\MailboxSizeReport.csv",
    [switch]$IncludePublicFolders,
    [string]$PFMailboxExportPath = "C:\temp\PublicFolderMailboxSizeReport.csv",
    [string]$PFExportPath = "C:\temp\PublicFolderSizeReport.csv"
)

# --- Helper: make sure a folder exists for a given file path ---
function Ensure-FolderExists {
    param([string]$Path)
    $folder = Split-Path -Path $Path -Parent
    if ($folder -and -not (Test-Path -Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
    }
}

Ensure-FolderExists -Path $ExportPath

# --- Sanity check: make sure Exchange cmdlets are available ---
if (-not (Get-Command Get-Mailbox -ErrorAction SilentlyContinue)) {
    Write-Error "Get-Mailbox not found. Run this from the Exchange Management Shell, or import a remote Exchange PowerShell session first."
    return
}

Write-Host "Gathering mailbox list..." -ForegroundColor Cyan

$mailboxParams = @{ ResultSize = 'Unlimited' }
if ($OrganizationalUnit) { $mailboxParams['OrganizationalUnit'] = $OrganizationalUnit }

$mailboxes = @(Get-Mailbox @mailboxParams)

Write-Host "Found $($mailboxes.Count) mailboxes. Pulling size and quota statistics (this can take a while for large orgs)..." -ForegroundColor Cyan

$results = New-Object System.Collections.Generic.List[Object]
$count = 0

foreach ($mbx in $mailboxes) {

    $count++
    Write-Progress -Activity "Retrieving mailbox statistics" -Status $mbx.DisplayName `
        -PercentComplete (($count / $mailboxes.Count) * 100)

    # --- Current size / item count ---
    $stats = Get-MailboxStatistics -Identity $mbx.Identity -ErrorAction SilentlyContinue

    $currentSizeBytes = 0
    $currentSizeString = 'N/A'
    $itemCount = 0
    if ($stats) {
        $itemCount = $stats.ItemCount
        if ($stats.TotalItemSize -and $null -ne $stats.TotalItemSize.Value) {
            try {
                $currentSizeBytes = $stats.TotalItemSize.Value.ToBytes()
                $currentSizeString = $stats.TotalItemSize.Value.ToString()
            }
            catch {
                $currentSizeBytes = 0
                $currentSizeString = 'N/A'
            }
        }
    }

    # --- Determine effective quota (per-mailbox override, or database default) ---
    $usesDefault = $mbx.UseDatabaseQuotaDefaults

    if ($usesDefault) {
        $db = Get-MailboxDatabase -Identity $mbx.Database -ErrorAction SilentlyContinue
        $warnQuota   = $db.IssueWarningQuota
        $sendQuota   = $db.ProhibitSendQuota
        $sendRcvQuota = $db.ProhibitSendReceiveQuota
    }
    else {
        $warnQuota    = $mbx.IssueWarningQuota
        $sendQuota    = $mbx.ProhibitSendQuota
        $sendRcvQuota = $mbx.ProhibitSendReceiveQuota
    }

    # Convert quota to bytes for percent calculation (handle "Unlimited")
    $sendRcvBytes = $null
    if ($sendRcvQuota -and $sendRcvQuota.ToString() -ne 'Unlimited' -and $null -ne $sendRcvQuota.Value) {
        try { $sendRcvBytes = $sendRcvQuota.Value.ToBytes() } catch { $sendRcvBytes = $null }
    }

    $percentUsed = if ($sendRcvBytes -and $sendRcvBytes -gt 0) {
        [math]::Round(($currentSizeBytes / $sendRcvBytes) * 100, 1)
    } else {
        $null
    }

    $results.Add([PSCustomObject]@{
        DisplayName          = $mbx.DisplayName
        Alias                = $mbx.Alias
        Database             = $mbx.Database
        CurrentSize           = $currentSizeString
        ItemCount             = $itemCount
        QuotaSource           = if ($usesDefault) { 'Database Default' } else { 'Custom (Per-Mailbox)' }
        IssueWarningQuota     = $warnQuota
        ProhibitSendQuota     = $sendQuota
        ProhibitSendReceiveQuota = $sendRcvQuota
        PercentOfMaxUsed      = if ($null -ne $percentUsed) { "$percentUsed%" } else { 'Unlimited' }
    })
}

Write-Progress -Activity "Retrieving mailbox statistics" -Completed

# --- Output ---
if ($ExportPath) {
    $results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Report exported to $ExportPath" -ForegroundColor Green
}
else {
    $results | Sort-Object PercentOfMaxUsed -Descending | Format-Table -AutoSize
}

# =========================================================================
#  PUBLIC FOLDERS (optional)
# =========================================================================
if ($IncludePublicFolders) {

    # -----------------------------------------------------------------
    # 1) Public folder MAILBOXES - the mailboxes that host PF content.
    #    These behave like regular mailboxes for size/quota purposes.
    # -----------------------------------------------------------------
    Write-Host "`nGathering public folder mailboxes..." -ForegroundColor Cyan

    Ensure-FolderExists -Path $PFMailboxExportPath
    $pfMailboxResults = New-Object System.Collections.Generic.List[Object]

    $pfMailboxes = @(Get-Mailbox -PublicFolder -ResultSize Unlimited -ErrorAction SilentlyContinue)

    if ($pfMailboxes.Count -gt 0) {
        $pfCount = 0
        foreach ($pfmbx in $pfMailboxes) {

            $pfCount++
            $pfPct = if ($pfMailboxes.Count -gt 0) { ($pfCount / $pfMailboxes.Count) * 100 } else { 0 }
            Write-Progress -Activity "Retrieving public folder mailbox statistics" -Status $pfmbx.DisplayName `
                -PercentComplete $pfPct

            $pfStats = Get-MailboxStatistics -Identity $pfmbx.Identity -ErrorAction SilentlyContinue

            $pfCurrentBytes = 0
            $pfCurrentSizeString = 'N/A'
            $pfItemCount = 0
            if ($pfStats) {
                $pfItemCount = $pfStats.ItemCount
                if ($pfStats.TotalItemSize -and $null -ne $pfStats.TotalItemSize.Value) {
                    try {
                        $pfCurrentBytes = $pfStats.TotalItemSize.Value.ToBytes()
                        $pfCurrentSizeString = $pfStats.TotalItemSize.Value.ToString()
                    }
                    catch {
                        $pfCurrentBytes = 0
                        $pfCurrentSizeString = 'N/A'
                    }
                }
            }

            $pfUsesDefault = $pfmbx.UseDatabaseQuotaDefaults
            if ($pfUsesDefault) {
                $pfDb = Get-MailboxDatabase -Identity $pfmbx.Database -ErrorAction SilentlyContinue
                $pfWarn   = $pfDb.IssueWarningQuota
                $pfSend   = $pfDb.ProhibitSendQuota
                $pfSendRcv = $pfDb.ProhibitSendReceiveQuota
            }
            else {
                $pfWarn    = $pfmbx.IssueWarningQuota
                $pfSend    = $pfmbx.ProhibitSendQuota
                $pfSendRcv = $pfmbx.ProhibitSendReceiveQuota
            }

            $pfSendRcvBytes = $null
            if ($pfSendRcv -and $pfSendRcv.ToString() -ne 'Unlimited' -and $null -ne $pfSendRcv.Value) {
                try { $pfSendRcvBytes = $pfSendRcv.Value.ToBytes() } catch { $pfSendRcvBytes = $null }
            }

            $pfPercent = if ($pfSendRcvBytes -and $pfSendRcvBytes -gt 0) {
                [math]::Round(($pfCurrentBytes / $pfSendRcvBytes) * 100, 1)
            } else { $null }

            $pfMailboxResults.Add([PSCustomObject]@{
                DisplayName              = $pfmbx.DisplayName
                Database                 = $pfmbx.Database
                CurrentSize              = $pfCurrentSizeString
                ItemCount                = $pfItemCount
                QuotaSource              = if ($pfUsesDefault) { 'Database Default' } else { 'Custom (Per-Mailbox)' }
                IssueWarningQuota        = $pfWarn
                ProhibitSendQuota        = $pfSend
                ProhibitSendReceiveQuota = $pfSendRcv
                PercentOfMaxUsed         = if ($null -ne $pfPercent) { "$pfPercent%" } else { 'Unlimited' }
            })
        }
        Write-Progress -Activity "Retrieving public folder mailbox statistics" -Completed

        $pfMailboxResults | Export-Csv -Path $PFMailboxExportPath -NoTypeInformation -Encoding UTF8
        Write-Host "Public folder mailbox report exported to $PFMailboxExportPath" -ForegroundColor Green
    }
    else {
        Write-Host "No public folder mailboxes found (legacy PF databases use a different cmdlet - see notes)." -ForegroundColor Yellow
    }

    # -----------------------------------------------------------------
    # 2) Individual PUBLIC FOLDERS - size/item count per folder, plus
    #    the quota that actually applies to each one (per-folder
    #    override if set, otherwise the org-wide default).
    # -----------------------------------------------------------------
    Write-Host "`nGathering individual public folder sizes (this can take a while for large PF trees)..." -ForegroundColor Cyan

    Ensure-FolderExists -Path $PFExportPath
    $pfFolderResults = New-Object System.Collections.Generic.List[Object]

    # Org-wide default PF quotas (used when a folder has no per-folder override)
    $orgConfig = Get-OrganizationConfig -ErrorAction SilentlyContinue
    $defaultIssueWarn  = $orgConfig.DefaultPublicFolderIssueWarningQuota
    $defaultProhibPost = $orgConfig.DefaultPublicFolderProhibitPostQuota
    $defaultMaxItem    = $orgConfig.DefaultPublicFolderMaxItemSize

    $publicFolders = @(Get-PublicFolder -Recurse -ResultSize Unlimited -ErrorAction SilentlyContinue)

    if ($publicFolders.Count -gt 0) {
        $folderCount = 0
        foreach ($folder in $publicFolders) {

            $folderCount++
            $folderPct = if ($publicFolders.Count -gt 0) { ($folderCount / $publicFolders.Count) * 100 } else { 0 }
            Write-Progress -Activity "Retrieving public folder statistics" -Status $folder.Identity `
                -PercentComplete $folderPct

            $folderStats = Get-PublicFolderStatistics -Identity $folder.Identity -ErrorAction SilentlyContinue

            $folderBytes = 0
            $folderSizeString = 'N/A'
            if ($folderStats -and $folderStats.TotalItemSize -and $null -ne $folderStats.TotalItemSize.Value) {
                try {
                    $folderBytes = $folderStats.TotalItemSize.Value.ToBytes()
                    $folderSizeString = $folderStats.TotalItemSize.Value.ToString()
                }
                catch {
                    $folderBytes = 0
                    $folderSizeString = 'N/A'
                }
            }

            # Per-folder override, if set, otherwise org default
            $issueWarn  = if ($folder.IssueWarningQuota  -and $folder.IssueWarningQuota.ToString()  -ne 'Unlimited') { $folder.IssueWarningQuota }  else { $defaultIssueWarn }
            $prohibPost = if ($folder.ProhibitPostQuota   -and $folder.ProhibitPostQuota.ToString()   -ne 'Unlimited') { $folder.ProhibitPostQuota }   else { $defaultProhibPost }

            $prohibPostBytes = $null
            if ($prohibPost -and $prohibPost.ToString() -ne 'Unlimited' -and $null -ne $prohibPost.Value) {
                try { $prohibPostBytes = $prohibPost.Value.ToBytes() } catch { $prohibPostBytes = $null }
            }

            $folderPercent = if ($prohibPostBytes -and $prohibPostBytes -gt 0) {
                [math]::Round(($folderBytes / $prohibPostBytes) * 100, 1)
            } else { $null }

            $pfFolderResults.Add([PSCustomObject]@{
                FolderPath         = $folder.Identity
                MailEnabled        = $folder.MailEnabled
                CurrentSize        = $folderSizeString
                ItemCount          = if ($folderStats) { $folderStats.ItemCount } else { 0 }
                IssueWarningQuota  = $issueWarn
                ProhibitPostQuota  = $prohibPost
                PercentOfMaxUsed   = if ($null -ne $folderPercent) { "$folderPercent%" } else { 'Unlimited' }
            })
        }
        Write-Progress -Activity "Retrieving public folder statistics" -Completed

        $pfFolderResults | Export-Csv -Path $PFExportPath -NoTypeInformation -Encoding UTF8
        Write-Host "Public folder (per-folder) report exported to $PFExportPath" -ForegroundColor Green
    }
    else {
        Write-Host "No public folders found, or Get-PublicFolder is unavailable in this environment." -ForegroundColor Yellow
    }
}
