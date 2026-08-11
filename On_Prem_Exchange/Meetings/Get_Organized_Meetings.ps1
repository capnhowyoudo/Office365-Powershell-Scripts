<#
.SYNOPSIS
    Enumerates upcoming calendar meetings for a mailbox where that mailbox is the ORGANIZER,
    using EWS Managed API with impersonation. Outputs to console and CSV.

.NOTES
    Requires:
      - EWS Managed API installed on the machine running this script.

        If the EWS Managed API DLL is not already available, obtain and stage it as follows:
          1. Download:  https://www.nuget.org/api/v2/package/Exchange.WebServices.Managed.Api/2.2.1.2
          2. Rename the downloaded file from .nupkg to .zip, then extract it.
          3. Copy lib\net35\Microsoft.Exchange.WebServices.dll to C:\temp\
          4. Run this script from C:\temp (or pass -EwsDllPath pointing at the DLL's location).

      - The account running this script must have ApplicationImpersonation rights
        over the target mailbox (you already have this via Organization Management).
      - Run from a machine that can reach the Exchange server's EWS endpoint
        (usually https://<CAS-server-or-namespace>/EWS/Exchange.asmx)

        To find your environment's EWS URL(s) instead of guessing, run this from an
        Exchange Management Shell (on-prem) session:
        
        Get-ExchangeServer | Select Name, Fqdn | ForEach-Object { [PSCustomObject]@{ Server = $_.Name; EwsUrl = "https://$($_.Fqdn)/EWS/Exchange.asmx" } }
        or
        Get-WebServicesVirtualDirectory | Select Server, InternalUrl, ExternalUrl
        
        Use the InternalUrl (or ExternalUrl, if connecting from outside the network)
        value returned for the appropriate CAS server as the -EwsUrl parameter below.

.PARAMETER MailboxSmtp
    SMTP address of the shared mailbox to inspect.

.PARAMETER EwsUrl
    Full URL to the EWS endpoint. Adjust to your environment, e.g.
    https://<your-cas-server-or-namespace>/EWS/Exchange.asmx
    or leave as autodiscover (recommended if Autodiscover is healthy).

.PARAMETER DaysForward
    How many days into the future to search for meetings.

.EXAMPLE
    .\Get_Organized_Meetings.ps1 -MailboxSmtp "user@example.com" -DaysForward 730

.EXAMPLE
    .\Get_Organized_Meetings.ps1 -MailboxSmtp "user@example.com" -EwsUrl "https://exchange-server.example.local/EWS/Exchange.asmx" -DaysForward 730 -IgnoreSslErrors

.EXAMPLE
    $cred = Get-Credential
    # When prompted, enter: domain\ServiceAccount (or whatever its exact logon name is)
    # and its password

    .\Get_Organized_Meetings.ps1 -MailboxSmtp "user@example.com" -EwsUrl "https://exchange-server.example.local/EWS/Exchange.asmx" -DaysForward 730 -IgnoreSslErrors -ExplicitCredential $cred
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxSmtp,

    [Parameter(Mandatory = $false)]
    [string]$EwsUrl,  # leave blank to use Autodiscover

    [Parameter(Mandatory = $false)]
    [int]$DaysForward = 730,

    [Parameter(Mandatory = $false)]
    [string]$OutputCsv = ".\OrganizedMeetings_$($MailboxSmtp -replace '[^a-zA-Z0-9]','_').csv",

    [Parameter(Mandatory = $false)]
    [string]$EwsDllPath,  # optional override; script also checks common install/extract locations below

    [Parameter(Mandatory = $false)]
    [switch]$IgnoreSslErrors,  # troubleshooting only - bypasses cert validation for internal/self-signed certs

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$ExplicitCredential  # use if the logged-in session isn't the account with impersonation rights
)

# ---- Load EWS Managed API ----
# Old MSI download link is retired. Easiest current source: NuGet package
# "Exchange.WebServices.Managed.Api" -> extract -> lib\net35\Microsoft.Exchange.WebServices.dll
# https://www.nuget.org/packages/Exchange.WebServices.Managed.Api
$candidatePaths = @(
    $EwsDllPath,
    "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll",
    "C:\temp\Microsoft.Exchange.WebServices.dll",
    ".\Microsoft.Exchange.WebServices.dll"
) | Where-Object { $_ }

$ewsDllPath = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $ewsDllPath) {
    Write-Error "EWS Managed API DLL not found in any of the expected locations. Download it from https://www.nuget.org/api/v2/package/Exchange.WebServices.Managed.Api/2.2.1.2, rename the .nupkg to .zip, extract it, grab lib\net35\Microsoft.Exchange.WebServices.dll, and either place it in C:\temp\ or pass -EwsDllPath <path-to-dll>."
    return
}
Write-Host "Using EWS Managed API DLL: $ewsDllPath"

# Load via byte array instead of Add-Type -Path. This avoids Mark-of-the-Web / zone-based
# FileLoadException (HRESULT 0x80131515) that persists even after Unblock-File in some
# AV/EDR or Group Policy configurations, since byte-array loads skip the zone check entirely.
try {
    $bytes = [System.IO.File]::ReadAllBytes($ewsDllPath)
    [System.Reflection.Assembly]::Load($bytes) | Out-Null
} catch {
    Write-Error "Failed to load EWS DLL even via byte-array load: $($_.Exception.Message)"
    return
}

# Force TLS 1.2 - older default SecurityProtocol settings can cause SSL/TLS trust errors
# against modern Exchange EWS endpoints even when the cert itself is fine.
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

if ($IgnoreSslErrors) {
    Write-Warning "Bypassing SSL certificate validation (-IgnoreSslErrors). Use only for troubleshooting against a known-internal server - never in production long-term."
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
}

# ---- Connect ----
$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2016)

# ---- Credentials ----
# UseDefaultCredentials only works if the account running THIS PowerShell session is the
# one with ApplicationImpersonation rights. If your logged-in session is a different
# account than the one granted impersonation rights, pass -ExplicitCredential
# to authenticate as that specific account instead.
if ($ExplicitCredential) {
    $service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials($ExplicitCredential)
} else {
    $service.UseDefaultCredentials = $true
}

if ($EwsUrl) {
    $service.Url = New-Object System.Uri($EwsUrl)
} else {
    Write-Host "Performing Autodiscover for $MailboxSmtp ..."
    try {
        $service.AutodiscoverUrl($MailboxSmtp, {$true})
    } catch {
        Write-Error "Autodiscover failed: $($_.Exception.Message)`nPass -EwsUrl explicitly, e.g. -EwsUrl `"https://<your-cas-server-or-namespace>/EWS/Exchange.asmx`". You can find the correct URL by running: Get-WebServicesVirtualDirectory | Select Server, InternalUrl, ExternalUrl"
        return
    }
}

# Impersonate the target mailbox
$service.ImpersonatedUserId = New-Object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId(
    [Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress,
    $MailboxSmtp
)

# ---- Build calendar view ----
$startDate = (Get-Date)
$endDate   = $startDate.AddDays($DaysForward)

$calendarFolderId = New-Object Microsoft.Exchange.WebServices.Data.FolderId(
    [Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar, $MailboxSmtp
)

$calendarView = New-Object Microsoft.Exchange.WebServices.Data.CalendarView($startDate, $endDate, 2000)
$calendarView.PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet(
    [Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties
)

Write-Host "Querying calendar for $MailboxSmtp from $startDate to $endDate ..."
try {
    $appointments = $service.FindAppointments($calendarFolderId, $calendarView)
} catch {
    Write-Error "FindAppointments failed: $($_.Exception.Message)`nThis usually means the service.Url was never set (Autodiscover failed) or impersonation rights are missing/not propagated yet."
    return
}

$results = @()

foreach ($appt in $appointments.Items) {
    # Bind fully to get organizer + attendee detail
    $full = [Microsoft.Exchange.WebServices.Data.Appointment]::Bind($service, $appt.Id)

    $organizerEmail = $null
    if ($full.Organizer) { $organizerEmail = $full.Organizer.Address }

    $isOrganizer = ($organizerEmail -and ($organizerEmail.ToLower() -eq $MailboxSmtp.ToLower()))

    $attendeeCount = 0
    if ($full.RequiredAttendees) { $attendeeCount += $full.RequiredAttendees.Count }
    if ($full.OptionalAttendees) { $attendeeCount += $full.OptionalAttendees.Count }

    $results += [PSCustomObject]@{
        Subject        = $full.Subject
        Start           = $full.Start
        End             = $full.End
        IsOrganizer     = $isOrganizer
        Organizer       = $organizerEmail
        AttendeeCount   = $attendeeCount
        IsRecurring     = $full.IsRecurring
        ItemId          = $full.Id.UniqueId
    }
}

$organizedOnly = $results | Where-Object { $_.IsOrganizer -eq $true }

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Total calendar items in window: $($results.Count)"
Write-Host "Items organized by $($MailboxSmtp): $($organizedOnly.Count)"
Write-Host ""

if ($organizedOnly.Count -gt 0) {
    $organizedOnly | Sort-Object Start | Format-Table Subject, Start, AttendeeCount, IsRecurring -AutoSize
}

$results | Sort-Object Start | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
Write-Host "Full results (organizer + non-organizer) exported to: $OutputCsv"
