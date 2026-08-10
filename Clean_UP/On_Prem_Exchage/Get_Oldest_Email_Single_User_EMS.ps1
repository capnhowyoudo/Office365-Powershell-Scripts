<#
.SYNOPSIS
    Finds the oldest email in an on-premise Exchange mailbox using native
    Exchange Management Shell cmdlets (no EWS API required).

.DESCRIPTION
    Run this from the Exchange Management Shell (or a remote PowerShell session
    with the Exchange snap-in loaded). It uses Get-MailboxFolderStatistics,
    which exposes an OldestItemReceivedDate property per folder, to find which
    folder holds the oldest item and when it was received.

    If Search-Mailbox is available in your Exchange version (deprecated in
    newer builds, removed starting around Exchange 2019 CU12+), the script
    will also try to pull back the Subject/Sender of that oldest item.

.PARAMETER Mailbox
    Identity of the mailbox (alias, SMTP address, or display name).

.PARAMETER IncludeMessageDetails
    If set, attempts to use Search-Mailbox to retrieve Subject/Sender of the
    oldest item. Requires the Mailbox Import Export RBAC role and that
    Search-Mailbox still exists in your Exchange build.

.EXAMPLE
    .\Get_Oldest_Email_Single_User_EMS.ps1 -Mailbox jsmith

.EXAMPLE
    .\Get_Oldest_Email_Single_User_EMS.ps1 -Mailbox jsmith@contoso.com -IncludeMessageDetails

.NOTES
    Run directly in the Exchange Management Shell console, or from a regular
    PowerShell session after running:
        Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
    or connecting via remote PowerShell to your CAS/Mailbox server.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Mailbox,

    [switch]$IncludeMessageDetails
)

# Sanity check: are we in an Exchange-aware shell?
if (-not (Get-Command Get-MailboxFolderStatistics -ErrorAction SilentlyContinue)) {
    Write-Error "Get-MailboxFolderStatistics not found. Run this in the Exchange Management Shell, or load the Exchange snap-in / remote session first."
    return
}

Write-Host "Scanning folders in mailbox '$Mailbox'..." -ForegroundColor Cyan

# Pull per-folder stats, including OldestItemReceivedDate
$folderStats = Get-MailboxFolderStatistics -Identity $Mailbox -IncludeOldestAndNewestItems |
    Where-Object { $_.ItemsInFolder -gt 0 -and $_.OldestItemReceivedDate } |
    Select-Object FolderPath, ItemsInFolder, OldestItemReceivedDate

if (-not $folderStats) {
    Write-Output "No folders with items/dates found for mailbox '$Mailbox'."
    Write-Output "Note: OldestItemReceivedDate is only populated for folders that have a retention/MRM tag applied. If none is assigned, this may stay blank for every folder - use the EWS-based script instead in that case."
    return
}

# Find the folder with the overall oldest item
$oldestFolder = $folderStats | Sort-Object OldestItemReceivedDate | Select-Object -First 1

Write-Host "`nOldest item found in folder: $($oldestFolder.FolderPath)" -ForegroundColor Green
Write-Host "Received: $($oldestFolder.OldestItemReceivedDate)"
Write-Host "Items in that folder: $($oldestFolder.ItemsInFolder)"

# Optionally try to get the actual message details (Subject/Sender)
if ($IncludeMessageDetails) {
    if (-not (Get-Command Search-Mailbox -ErrorAction SilentlyContinue)) {
        Write-Warning "Search-Mailbox is not available on this Exchange build. Skipping message detail lookup. (It was deprecated/removed in newer CUs; use eDiscovery/Compliance Search or EWS instead.)"
    } else {
        $searchDate = $oldestFolder.OldestItemReceivedDate.ToString("MM/dd/yyyy")
        $targetFolderLeaf = ($oldestFolder.FolderPath.Split("/") | Select-Object -Last 1)

        Write-Host "`nAttempting to retrieve message details via Search-Mailbox..." -ForegroundColor Cyan

        # Search-Mailbox requires a target mailbox to copy results into (it can't just "preview" without one
        # in most versions), so we point results at the same mailbox in a dedicated search folder.
        $searchResult = Search-Mailbox -Identity $Mailbox `
            -SearchQuery "received:$searchDate" `
            -TargetMailbox $Mailbox `
            -TargetFolder "OldestItemSearchResults" `
            -LogOnly `
            -LogLevel Full

        if ($searchResult) {
            Write-Host "Search-Mailbox ran in log-only mode. Check the returned log for message details:" -ForegroundColor Yellow
            $searchResult | Select-Object TargetMailbox, ResultItemsCount, TargetFolder | Format-List
            Write-Host "Tip: remove -LogOnly to actually copy the matching message(s) into '$($Mailbox)\OldestItemSearchResults' for inspection." -ForegroundColor Yellow
        } else {
            Write-Warning "Search-Mailbox returned no result object."
        }
    }
}

# Full folder breakdown, oldest first, in case you want to see everything
Write-Host "`nAll folders sorted by oldest item date:" -ForegroundColor Cyan
$folderStats | Sort-Object OldestItemReceivedDate | Format-Table -AutoSize
