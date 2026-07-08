<#
.SYNOPSIS
    Shows the last email received AND the last email sent for a single
    Office 365 (Microsoft 365) mailbox.

.DESCRIPTION
    Uses the Microsoft Graph PowerShell SDK. Unlike message trace based
    approaches, Graph queries against actual mailbox content directly, so
    there's no rolling retention window to worry about - it simply returns
    whatever the true newest item is, regardless of age.

    Last received: queries across the ENTIRE mailbox (all folders - Inbox,
    Deleted Items, Clutter/Junk, custom subfolders, etc.) sorted by
    receivedDateTime, since Graph's /messages endpoint already spans all
    folders by default.

    Last sent: queries the Sent Items folder specifically, sorted by
    sentDateTime.

    AUTHENTICATION - app-only (application permissions) only. This lets the
    script read ANY mailbox in the tenant as an admin, without per-user
    delegation. Requires -AppId, -TenantId, and -CertificateThumbprint.

    One-time setup in Entra ID for app-only mode:
      a. App registrations > New registration.
      b. API permissions > Microsoft Graph > Application permissions >
         add Mail.Read > Grant admin consent.
      c. Certificates & secrets > upload a certificate and note its
         thumbprint.
      d. Install that certificate in your local cert store, then pass
         the Application (client) ID, Directory (tenant) ID, and
         certificate thumbprint below.

    Full step-by-step how-to (with screenshots):
      https://github.com/capnhowyoudo/Office365-Powershell-Scripts/blob/main/Mailbox_Reporting/Setting_Up_App-Only_Access_for_Mailbox%20Reporting_Scripts.md

    Requires:
      - Microsoft.Graph.Mail module (Install-Module Microsoft.Graph)
      - Mail.Read (application) permission, admin consented.

.PARAMETER Mailbox
    The UPN or email address of the mailbox to check (e.g. user@contoso.com).

.PARAMETER AppId
    The Application (client) ID of your Entra ID app registration.

.PARAMETER TenantId
    The Directory (tenant) ID.

.PARAMETER CertificateThumbprint
    Thumbprint of the certificate registered on the app registration,
    installed in the current user's certificate store.

.EXAMPLE
    .\Get_LastReceived-Sent_Email_Single_User.ps1 -Mailbox user@contoso.com `
        -AppId "11111111-1111-1111-1111-111111111111" `
        -TenantId "22222222-2222-2222-2222-222222222222" `
        -CertificateThumbprint "AB12CD34EF56..."
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Mailbox,

    [Parameter(Mandatory = $true)]
    [string]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$CertificateThumbprint
)

# Ensure the required module is available
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Mail)) {
    Write-Host "Microsoft.Graph.Mail module not found. Installing..." -ForegroundColor Yellow
    Install-Module Microsoft.Graph.Mail -Scope CurrentUser -Force -AllowClobber
}

Import-Module Microsoft.Graph.Mail

try {
    Connect-MgGraph -ClientId $AppId -TenantId $TenantId -CertificateThumbprint $CertificateThumbprint -NoWelcome

    # ---------- LAST RECEIVED (across the whole mailbox) ----------
    Write-Host "=== Last Received ===" -ForegroundColor Cyan

    $lastReceived = Get-MgUserMessage -UserId $Mailbox `
        -Top 1 `
        -OrderBy "receivedDateTime desc" `
        -Property "subject,from,receivedDateTime,isRead,parentFolderId" `
        -ErrorAction Stop

    if ($lastReceived) {
        $folderName = $lastReceived.ParentFolderId
        try {
            $folder = Get-MgUserMailFolder -UserId $Mailbox -MailFolderId $lastReceived.ParentFolderId -ErrorAction Stop
            if ($folder) { $folderName = $folder.DisplayName }
        }
        catch { }

        [PSCustomObject]@{
            Mailbox  = $Mailbox
            Folder   = $folderName
            From     = $lastReceived.From.EmailAddress.Address
            Subject  = $lastReceived.Subject
            Received = $lastReceived.ReceivedDateTime
            IsRead   = $lastReceived.IsRead
        } | Format-List
    }
    else {
        Write-Host "No received items found in $Mailbox's mailbox." -ForegroundColor Yellow
    }

    # ---------- LAST SENT (Sent Items folder) ----------
    Write-Host "`n=== Last Sent ===" -ForegroundColor Cyan

    $lastSent = Get-MgUserMailFolderMessage -UserId $Mailbox -MailFolderId "SentItems" `
        -Top 1 `
        -OrderBy "sentDateTime desc" `
        -Property "subject,toRecipients,sentDateTime" `
        -ErrorAction Stop

    if ($lastSent) {
        [PSCustomObject]@{
            Mailbox = $Mailbox
            To      = ($lastSent.ToRecipients | ForEach-Object { $_.EmailAddress.Address }) -join "; "
            Subject = $lastSent.Subject
            Sent    = $lastSent.SentDateTime
        } | Format-List
    }
    else {
        Write-Host "No sent items found in $Mailbox's Sent Items folder." -ForegroundColor Yellow
    }
}
catch {
    $err = $_.Exception.Message
    Write-Host "Error retrieving mailbox data: $err" -ForegroundColor Red
    if ($err -match "Access is denied" -or $err -match "ErrorAccessDenied" -or $err -match "Forbidden") {
        Write-Host ""
        Write-Host "Double-check that Mail.Read (Application permission, not" -ForegroundColor Yellow
        Write-Host "Delegated) has been granted admin consent for this app" -ForegroundColor Yellow
        Write-Host "registration in Entra ID." -ForegroundColor Yellow
    }
}
finally {
    Disconnect-MgGraph | Out-Null
}
