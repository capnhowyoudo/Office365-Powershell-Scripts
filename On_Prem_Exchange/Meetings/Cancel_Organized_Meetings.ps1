<#
.SYNOPSIS
    Cancels meetings/recurring series organized by a mailbox, using EWS impersonation.
    Sends cancellation notices to attendees and removes the meeting(s) from the organizer's calendar.

.NOTES
    Defaults to DRY RUN - shows what would be canceled without actually doing it.
    Pass -Execute to actually send cancellations. This cannot be easily undone once sent.

    Requires the EWS Managed API DLL to be present (see candidate paths below, or pass -EwsDllPath).
    If it is not already installed, obtain and stage it as follows:
      * Download: https://www.nuget.org/api/v2/package/Exchange.WebServices.Managed.Api/2.2.1.2
      * Rename the downloaded file from .nupkg to .zip, then extract it
      * Copy lib\net35\Microsoft.Exchange.WebServices.dll to C:\temp\
      * Run this script from C:\temp

    To find the -EwsUrl value for your environment, run one of the following from the Exchange Management Shell:
      Get-ExchangeServer | Select Name, Fqdn | ForEach-Object { [PSCustomObject]@{ Server = $_.Name; EwsUrl = "https://$($_.Fqdn)/EWS/Exchange.asmx" } }
      or
      Get-WebServicesVirtualDirectory | Select Server, InternalUrl, ExternalUrl

.PARAMETER MailboxSmtp
    SMTP address of the organizing mailbox.

.PARAMETER SubjectFilter
    One or more subject strings to match (exact or partial - see -PartialMatch).
    Only items matching these subjects will be canceled. This is a safety guardrail
    so the script doesn't cancel EVERYTHING the mailbox organized by accident.

.PARAMETER PartialMatch
    If set, matches subjects containing the filter text rather than requiring an exact match.

.PARAMETER Execute
    Actually send the cancellations. Without this switch, the script only previews.

.EXAMPLE
    # Dry run - see what would be canceled
    .\Cancel_Organized_Meetings.ps1 -MailboxSmtp "user@example.com" `
        -EwsUrl "https://mail.example.com/EWS/Exchange.asmx" -IgnoreSslErrors `
        -ExplicitCredential $cred -SubjectFilter "Filter Audit","New Berlin Inventory (Weekly)"

.EXAMPLE
    # Actually cancel
    .\Cancel_Organized_Meetings.ps1 -MailboxSmtp "user@example.com" `
        -EwsUrl "https://mail.example.com/EWS/Exchange.asmx" -IgnoreSslErrors `
        -ExplicitCredential $cred -SubjectFilter "Filter Audit","New Berlin Inventory (Weekly)" -Execute
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxSmtp,

    [Parameter(Mandatory = $true)]
    [string[]]$SubjectFilter,

    [Parameter(Mandatory = $false)]
    [switch]$PartialMatch,

    [Parameter(Mandatory = $false)]
    [string]$EwsUrl,

    [Parameter(Mandatory = $false)]
    [string]$EwsDllPath,

    [Parameter(Mandatory = $false)]
    [switch]$IgnoreSslErrors,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$ExplicitCredential,

    [Parameter(Mandatory = $false)]
    [switch]$Execute,

    [Parameter(Mandatory = $false)]
    [string]$CancellationMessage = "This meeting has been canceled."
)

# ---- Load EWS Managed API (byte-array load to dodge MOTW blocking) ----
$candidatePaths = @(
    $EwsDllPath,
    "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll",
    "C:\temp\Microsoft.Exchange.WebServices.dll",
    ".\Microsoft.Exchange.WebServices.dll"
) | Where-Object { $_ }

$ewsDllPath = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $ewsDllPath) {
    Write-Error "EWS Managed API DLL not found. Pass -EwsDllPath or place it at C:\temp\Microsoft.Exchange.WebServices.dll"
    return
}
try {
    $bytes = [System.IO.File]::ReadAllBytes($ewsDllPath)
    [System.Reflection.Assembly]::Load($bytes) | Out-Null
} catch {
    Write-Error "Failed to load EWS DLL: $($_.Exception.Message)"
    return
}

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
if ($IgnoreSslErrors) {
    Write-Warning "Bypassing SSL certificate validation. Troubleshooting use only."
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
}

# ---- Connect ----
$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2016)

if ($ExplicitCredential) {
    $service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials($ExplicitCredential)
} else {
    $service.UseDefaultCredentials = $true
}

if ($EwsUrl) {
    $service.Url = New-Object System.Uri($EwsUrl)
} else {
    try {
        $service.AutodiscoverUrl($MailboxSmtp, {$true})
    } catch {
        Write-Error "Autodiscover failed: $($_.Exception.Message)"
        return
    }
}

$service.ImpersonatedUserId = New-Object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId(
    [Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress,
    $MailboxSmtp
)

# ---- Find actual calendar folder items (masters + single items - NOT expanded occurrences) ----
$calendarFolderId = New-Object Microsoft.Exchange.WebServices.Data.FolderId(
    [Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar, $MailboxSmtp
)

$itemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView(500)
$itemView.PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet(
    [Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties
)

try {
    $findResults = $service.FindItems($calendarFolderId, $itemView)
} catch {
    Write-Error "FindItems failed: $($_.Exception.Message)"
    return
}

$toCancel = @()

foreach ($item in $findResults.Items) {
    if ($item -isnot [Microsoft.Exchange.WebServices.Data.Appointment]) { continue }

    $matched = $false
    foreach ($f in $SubjectFilter) {
        if ($PartialMatch) {
            if ($item.Subject -like "*$f*") { $matched = $true; break }
        } else {
            if ($item.Subject -eq $f) { $matched = $true; break }
        }
    }
    if (-not $matched) { continue }

    $full = [Microsoft.Exchange.WebServices.Data.Appointment]::Bind($service, $item.Id)

    $organizerEmail = $null
    if ($full.Organizer) { $organizerEmail = $full.Organizer.Address }
    $isOrganizer = ($organizerEmail -and ($organizerEmail.ToLower() -eq $MailboxSmtp.ToLower()))

    if (-not $isOrganizer) {
        Write-Host "Skipping '$($full.Subject)' - $MailboxSmtp is not the organizer (organizer: $organizerEmail)" -ForegroundColor Yellow
        continue
    }

    $toCancel += $full
}

if ($toCancel.Count -eq 0) {
    Write-Host "No matching organizer items found for the given subject filter(s)." -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "=== Items matched for cancellation ===" -ForegroundColor Cyan
$toCancel | ForEach-Object {
    Write-Host (" - {0} | Start: {1} | Recurring: {2}" -f $_.Subject, $_.Start, $_.IsRecurring)
}
Write-Host ""

if (-not $Execute) {
    Write-Host "DRY RUN ONLY - no cancellations sent. Re-run with -Execute to actually cancel these." -ForegroundColor Green
    return
}

Write-Host "EXECUTING - sending cancellations now..." -ForegroundColor Red
foreach ($appt in $toCancel) {
    try {
        $appt.CancelMeeting($CancellationMessage)
        Write-Host "Canceled: $($appt.Subject)" -ForegroundColor Green
    } catch {
        Write-Host "FAILED to cancel '$($appt.Subject)': $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done. Verify in the mailbox's calendar and check a sample attendee's inbox for the cancellation notice."
