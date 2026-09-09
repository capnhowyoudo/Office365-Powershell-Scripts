<#
.SYNOPSIS
    Finds the oldest email in an Exchange Online mailbox.

.DESCRIPTION
    Run this after connecting to Exchange Online via the ExchangeOnlineManagement
    module. It uses Get-MailboxFolderStatistics (which exposes an
    OldestItemReceivedDate property per folder) to find which folder holds the
    oldest item and when it was received.

    Search-Mailbox does NOT work in Exchange Online (Microsoft has disabled it
    for most tenants and is retiring it entirely). If you need the actual
    Subject/Sender of the oldest item, this script instead kicks off a
    Content Search via the Security & Compliance PowerShell module
    (New-ComplianceSearch / Start-ComplianceSearch), which is asynchronous.

.PARAMETER Mailbox
    Identity of the mailbox (UPN or SMTP address).

.PARAMETER IncludeMessageDetails
    If set, creates and runs a Content Search for the oldest item's received
    date and waits for it to complete, then shows preview stats. Requires:
      - eDiscovery Manager (or higher) role assignment
      - A connection to the Security & Compliance PowerShell endpoint
        (Connect-IPPSSession), in ADDITION to Connect-ExchangeOnline

.EXAMPLE
    Connect-ExchangeOnline -UserPrincipalName admin@contoso.com
    .\Get_Oldest_Email_Single_User_EXO.ps1 -Mailbox jsmith@contoso.com

.EXAMPLE
    Connect-ExchangeOnline -UserPrincipalName admin@contoso.com
    Connect-IPPSSession -UserPrincipalName admin@contoso.com
    .\Get_Oldest_Email_Single_User_EXO.ps1 -Mailbox jsmith@contoso.com -IncludeMessageDetails

.NOTES
    Prereqs:
        Install-Module ExchangeOnlineManagement -Scope CurrentUser
    Then connect BEFORE running this script:
        Connect-ExchangeOnline -UserPrincipalName you@contoso.com
    And, only if using -IncludeMessageDetails:
        Connect-IPPSSession -UserPrincipalName you@contoso.com
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Mailbox,

    [switch]$IncludeMessageDetails
)

# Sanity check: are we connected to Exchange Online?
if (-not (Get-Command Get-MailboxFolderStatistics -ErrorAction SilentlyContinue)) {
    Write-Error "Get-MailboxFolderStatistics not found. Run Connect-ExchangeOnline first (Install-Module ExchangeOnlineManagement if needed)."
    return
}

Write-Host "Scanning folders in mailbox '$Mailbox'..." -ForegroundColor Cyan

# Pull per-folder stats, including OldestItemReceivedDate
# Note: in EXO this can be slow/throttled on very large mailboxes; that's normal.
$folderStats = Get-MailboxFolderStatistics -Identity $Mailbox -IncludeOldestAndNewestItems |
    Where-Object { $_.ItemsInFolder -gt 0 -and $_.OldestItemReceivedDate } |
    Select-Object FolderPath, ItemsInFolder, OldestItemReceivedDate

if (-not $folderStats) {
    Write-Output "No folders with items/dates found for mailbox '$Mailbox'."
    return
}

# Find the folder with the overall oldest item
$oldestFolder = $folderStats | Sort-Object OldestItemReceivedDate | Select-Object -First 1

Write-Host "`nOldest item found in folder: $($oldestFolder.FolderPath)" -ForegroundColor Green
Write-Host "Received: $($oldestFolder.OldestItemReceivedDate)"
Write-Host "Items in that folder: $($oldestFolder.ItemsInFolder)"

# Optionally try to get the actual message details (Subject/Sender) via Content Search
if ($IncludeMessageDetails) {
    if (-not (Get-Command New-ComplianceSearch -ErrorAction SilentlyContinue)) {
        Write-Warning "New-ComplianceSearch not found. Connect to the Security & Compliance endpoint first: Connect-IPPSSession -UserPrincipalName you@contoso.com"
    } else {
        $searchDate  = $oldestFolder.OldestItemReceivedDate.ToString("MM/dd/yyyy")
        $searchName  = "OldestItemLookup_$($Mailbox)_$(Get-Date -Format yyyyMMddHHmmss)"

        Write-Host "`nCreating Content Search '$searchName' for messages received $searchDate..." -ForegroundColor Cyan

        New-ComplianceSearch -Name $searchName `
            -ExchangeLocation $Mailbox `
            -ContentMatchQuery "received:$searchDate" | Out-Null

        Start-ComplianceSearch -Identity $searchName

        Write-Host "Search started. Polling for completion (this is asynchronous, may take a minute or more)..." -ForegroundColor Yellow

        do {
            Start-Sleep -Seconds 5
            $status = Get-ComplianceSearch -Identity $searchName
            Write-Host "  Status: $($status.Status)"
        } while ($status.Status -notin @("Completed", "Failed"))

        if ($status.Status -eq "Completed") {
            $status | Select-Object Name, Status, Items, Size | Format-List
            Write-Host "Tip: run 'New-ComplianceSearchAction -Identity `"$searchName`" -Preview' to see a message-level preview," -ForegroundColor Yellow
            Write-Host "  or '-Export' to export the actual item(s) for review." -ForegroundColor Yellow
        } else {
            Write-Warning "Content Search '$searchName' failed. Run Get-ComplianceSearch -Identity '$searchName' | fl for details."
        }
    }
}

# Full folder breakdown, oldest first, in case you want to see everything
Write-Host "`nAll folders sorted by oldest item date:" -ForegroundColor Cyan
$folderStats | Sort-Object OldestItemReceivedDate | Format-Table -AutoSize
