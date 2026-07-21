<#
.SYNOPSIS
    Tests SMTP connectivity to smtp.office365.com on port 587 and optionally sends a test email.

.DESCRIPTION
    This script performs two checks:
      1. A raw TCP/TLS connectivity test to smtp.office365.com:587 (STARTTLS), so you can see
         the actual SMTP conversation and diagnose network/firewall/auth issues.
      2. An optional real test email send using Send-MailMessage (or .NET SmtpClient) with
         basic auth or a supplied credential.

.PARAMETER From
    The sender's email address (must be a valid mailbox on your O365 tenant).

.PARAMETER To
    The recipient's email address.

.PARAMETER Credential
    PSCredential object for authentication. If omitted, you'll be prompted.

.PARAMETER SkipSend
    If specified, only runs the connectivity test and does not send an email.

.EXAMPLE
    .\Test_O365_SMTP_587.ps1 -From "user@contoso.com" -To "user@contoso.com"

.EXAMPLE
    .\Test_O365_SMTP_587.ps1 -From "user@contoso.com" -To "someone@else.com" -SkipSend

.EXAMPLE
    # If script execution is blocked by policy, bypass it for the current session only,
    # then build a credential and run the test:
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    $cred = Get-Credential
    .\Test_O365_SMTP_587.ps1 -From "user@example.com" -To "recipient@example.com" -Credential $cred

.NOTES
    Requires modern auth / SMTP AUTH to be enabled for the mailbox in Exchange Online if you
    intend to send mail (Microsoft has been disabling legacy SMTP AUTH by default since 2023).
    Check with: Get-CASMailbox -Identity user@contoso.com | Select SmtpClientAuthenticationDisabled
#>

[CmdletBinding()]
param(
    [string]$SmtpServer = "smtp.office365.com",
    [int]$Port = 587,
    [string]$From,
    [string]$To,
    [System.Management.Automation.PSCredential]$Credential,
    [switch]$SkipSend
)

function Test-SmtpPortConnectivity {
    param(
        [string]$Server,
        [int]$Port
    )

    Write-Host "`n=== Step 1: Raw TCP connectivity test to $Server`:$Port ===" -ForegroundColor Cyan

    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connectTask = $tcpClient.ConnectAsync($Server, $Port)
        $connected = $connectTask.Wait([TimeSpan]::FromSeconds(10))

        if (-not $connected -or -not $tcpClient.Connected) {
            Write-Host "FAILED: Could not establish TCP connection to $Server`:$Port within 10 seconds." -ForegroundColor Red
            Write-Host "This usually means port 587 outbound is blocked by a firewall or ISP." -ForegroundColor Yellow
            return $false
        }

        Write-Host "SUCCESS: TCP connection established." -ForegroundColor Green

        $stream = $tcpClient.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.AutoFlush = $true

        # Read the server's greeting banner
        Start-Sleep -Milliseconds 500
        $buffer = New-Object byte[] 4096
        $banner = ""
        while ($stream.DataAvailable) {
            $read = $stream.Read($buffer, 0, $buffer.Length)
            $banner += [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
        }
        Write-Host "Server banner:`n$banner" -ForegroundColor Gray

        # Send EHLO
        $writer.WriteLine("EHLO test-client")
        Start-Sleep -Milliseconds 500
        $ehloResponse = ""
        while ($stream.DataAvailable) {
            $read = $stream.Read($buffer, 0, $buffer.Length)
            $ehloResponse += [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
        }
        Write-Host "EHLO response:`n$ehloResponse" -ForegroundColor Gray

        if ($ehloResponse -match "STARTTLS") {
            Write-Host "STARTTLS capability confirmed." -ForegroundColor Green
        } else {
            Write-Host "WARNING: STARTTLS not advertised in EHLO response." -ForegroundColor Yellow
        }

        # Send QUIT
        $writer.WriteLine("QUIT")
        Start-Sleep -Milliseconds 300

        $reader.Close()
        $writer.Close()
        $stream.Close()
        $tcpClient.Close()

        return $true
    }
    catch {
        Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Send-TestEmail {
    param(
        [string]$Server,
        [int]$Port,
        [string]$From,
        [string]$To,
        [System.Management.Automation.PSCredential]$Cred
    )

    Write-Host "`n=== Step 2: Sending test email via $Server`:$Port ===" -ForegroundColor Cyan

    if (-not $Cred) {
        $Cred = Get-Credential -Message "Enter O365 mailbox credentials for $From"
    }

    $subject = "SMTP Test - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $body = "This is a test email sent via PowerShell to validate SMTP connectivity on port $Port against $Server."

    try {
        # Send-MailMessage is deprecated but still widely used/available.
        Send-MailMessage -SmtpServer $Server -Port $Port -UseSsl `
            -From $From -To $To -Subject $subject -Body $body `
            -Credential $Cred -ErrorAction Stop

        Write-Host "SUCCESS: Test email sent from $From to $To." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FAILED to send email: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Common causes:" -ForegroundColor Yellow
        Write-Host " - SMTP AUTH disabled for this mailbox (most common as of 2023+)" -ForegroundColor Yellow
        Write-Host " - Conditional Access / MFA blocking basic auth (use an app password or OAuth)" -ForegroundColor Yellow
        Write-Host " - Incorrect credentials" -ForegroundColor Yellow
        Write-Host " - Sending as an address you don't have 'Send As' rights to" -ForegroundColor Yellow
        return $false
    }
}

# ==================== Main ====================

Write-Host "Office 365 SMTP Connectivity Test" -ForegroundColor White
Write-Host "Target: $SmtpServer`:$Port`n" -ForegroundColor White

$portOk = Test-SmtpPortConnectivity -Server $SmtpServer -Port $Port

if (-not $portOk) {
    Write-Host "`nStopping: basic connectivity failed, skipping email send test." -ForegroundColor Red
    return
}

if ($SkipSend) {
    Write-Host "`n-SkipSend specified. Connectivity test complete." -ForegroundColor Cyan
    return
}

if (-not $From -or -not $To) {
    Write-Host "`nNo -From/-To supplied, skipping email send test. Re-run with -From and -To to send a real test email." -ForegroundColor Yellow
    return
}

Send-TestEmail -Server $SmtpServer -Port $Port -From $From -To $To -Cred $Credential
