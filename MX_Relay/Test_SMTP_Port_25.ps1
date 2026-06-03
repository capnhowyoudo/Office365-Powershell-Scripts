<#
.SYNOPSIS
    Tests SMTP connectivity on port 25 to a specified MX relay using a raw
    TCP (Telnet-style) socket connection.

.DESCRIPTION
    This script opens a raw TCP socket to a target MX relay host on port 25
    and walks through a full SMTP conversation manually — banner read, EHLO,
    MAIL FROM, RCPT TO, DATA, and QUIT — without relying on any high-level
    .NET mail client or external tools.

    It is the PowerShell equivalent of running:
        telnet <MXRelay> 25

    followed by manual SMTP commands. All server responses are captured and
    color-coded in the console. A result summary is printed at the end
    indicating whether the port is open, the relay accepted the recipient,
    or the connection was blocked.

    Typical use cases:
        - Confirm port 25 is not blocked by a local firewall or ISP
        - Verify an MX relay is reachable and responding to SMTP
        - Test inbound mail acceptance for a recipient address
        - Troubleshoot mail flow before configuring a mail client or server

.PARAMETER MXRelay
    The fully qualified domain name (FQDN) of the MX relay to connect to.
    Example: "mail-relay.example.com" or an Exchange Online protection host.

.PARAMETER Port
    The TCP port to connect on. Defaults to 25 (standard SMTP).

.PARAMETER From
    The sender address used in the MAIL FROM command.
    Example: "sender@yourdomain.com"

.PARAMETER To
    The recipient address used in the RCPT TO command.
    Example: "recipient@yourdomain.com"

.PARAMETER EhloDomain
    The domain name sent in the EHLO greeting. Should match the sending
    domain or the hostname of the machine running the script.
    Example: "yourdomain.com"

.PARAMETER TimeoutMs
    Read/write timeout in milliseconds for the TCP stream. Defaults to 5000.

.NOTES
    Author      : capnhowyoudo@yahoo.com
    Version     : 1.1
    Created     : 2026-06-01
    Requires    : PowerShell 5.1 or later (Windows); no external modules needed
    Permissions : No elevation required. Outbound port 25 must not be blocked
                  by a host firewall, corporate firewall, or ISP.

    RESULT CODES
    ------------
    250 on RCPT TO  -> Port 25 OPEN; relay accepted the recipient address.
    550-554 on RCPT -> Port 25 OPEN; relay rejected due to policy or auth.
    SocketException -> Port 25 BLOCKED or host unreachable.

    COMMON ISSUES
    -------------
    - Many residential ISPs block outbound port 25. Run from a server or VM.
    - Microsoft 365 / Exchange Online Protection MX relays require the sender
      domain to be verified; anonymous relay is restricted by default.
    - If the banner is received but RCPT TO is rejected with 550, this
      confirms connectivity is good but relay policy is the issue.

    USAGE EXAMPLES
    --------------
    # Run with defaults defined in the Variables section below:
        .\Test_SMTP_Port_25.ps1

    # Quick one-liner override using dot-sourcing or editing variables:
        $MXRelay = "mail.example.com"; .\Test_SMTP_Port_25.ps1
#>

# ==============================================================================
# VARIABLES  — update these before running
# ==============================================================================

$MXRelay    = "mail-relay.example.com"          # Target MX relay FQDN
$Port       = 25                                 # SMTP port (typically 25)
$From       = "sender@yourdomain.com"            # MAIL FROM address (This can be anything you want it to be as long as its @ the domain you are testing)
$To         = "recipient@yourdomain.com"         # RCPT TO address (This must be an email inside the domain you are testing with)
$EhloDomain = "yourdomain.com"                   # Domain used in EHLO greeting
$TimeoutMs  = 5000                               # TCP stream timeout (ms)

# ==============================================================================
# FUNCTION: Send-SMTPCommand
# ==============================================================================

function Send-SMTPCommand {
    param(
        [System.Net.Sockets.NetworkStream]$Stream,
        [System.IO.StreamReader]$Reader,
        [string]$Command
    )
    if ($Command) {
        Write-Host ">>> $Command" -ForegroundColor Yellow
        $bytes = [System.Text.Encoding]::ASCII.GetBytes("$Command`r`n")
        $Stream.Write($bytes, 0, $bytes.Length)
        $Stream.Flush()
    }
    Start-Sleep -Milliseconds 500
    $response = ""
    while ($Stream.DataAvailable) {
        $response += $Reader.ReadLine() + "`n"
        Start-Sleep -Milliseconds 100
    }
    if ($response) {
        Write-Host "<<< $($response.Trim())" -ForegroundColor Green
    }
    return $response
}

# ==============================================================================
# MAIN
# ==============================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " SMTP Port 25 Test via TCP (Telnet-style)"  -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "MX Relay    : $MXRelay"
Write-Host "Port        : $Port"
Write-Host "EHLO Domain : $EhloDomain"
Write-Host "From        : $From"
Write-Host "To          : $To"
Write-Host "Timeout     : ${TimeoutMs}ms"
Write-Host ""

try {
    # --- [1] Connect ---
    Write-Host "[1] Connecting to $MXRelay on port $Port ..." -ForegroundColor Cyan
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.Connect($MXRelay, $Port)

    if ($tcpClient.Connected) {
        Write-Host "    Connected successfully!`n" -ForegroundColor Green
    }

    $stream = $tcpClient.GetStream()
    $stream.ReadTimeout  = $TimeoutMs
    $stream.WriteTimeout = $TimeoutMs
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::ASCII)

    # --- [2] Read SMTP banner ---
    Write-Host "[2] Reading SMTP Banner:" -ForegroundColor Cyan
    Start-Sleep -Milliseconds 800
    $banner = ""
    while ($stream.DataAvailable) {
        $banner += $reader.ReadLine() + "`n"
        Start-Sleep -Milliseconds 100
    }
    Write-Host "<<< $($banner.Trim())" -ForegroundColor Green
    Write-Host ""

    # --- [3] EHLO ---
    Write-Host "[3] Sending EHLO:" -ForegroundColor Cyan
    $null = Send-SMTPCommand -Stream $stream -Reader $reader -Command "EHLO $EhloDomain"
    Write-Host ""

    # --- [4] MAIL FROM ---
    Write-Host "[4] Sending MAIL FROM:" -ForegroundColor Cyan
    $null = Send-SMTPCommand -Stream $stream -Reader $reader -Command "MAIL FROM:<$From>"
    Write-Host ""

    # --- [5] RCPT TO ---
    Write-Host "[5] Sending RCPT TO:" -ForegroundColor Cyan
    $rcptResponse = Send-SMTPCommand -Stream $stream -Reader $reader -Command "RCPT TO:<$To>"
    Write-Host ""

    # --- [6] DATA ---
    Write-Host "[6] Sending DATA:" -ForegroundColor Cyan
    $null = Send-SMTPCommand -Stream $stream -Reader $reader -Command "DATA"

    $emailBody  = "From: $From`r`n"
    $emailBody += "To: $To`r`n"
    $emailBody += "Subject: SMTP Port 25 Test - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n"
    $emailBody += "Date: $(Get-Date -Format 'ddd, dd MMM yyyy HH:mm:ss zzz')`r`n"
    $emailBody += "`r`n"
    $emailBody += "This is a test email sent via PowerShell TCP/SMTP on port 25.`r`n"
    $emailBody += "MX Relay    : $MXRelay`r`n"
    $emailBody += "EHLO Domain : $EhloDomain`r`n"
    $emailBody += "Sent        : $(Get-Date)`r`n"
    $emailBody += "."

    Write-Host ">>> [Sending email headers + body + end marker]" -ForegroundColor Yellow
    $bytes = [System.Text.Encoding]::ASCII.GetBytes("$emailBody`r`n")
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush()
    Start-Sleep -Milliseconds 800

    $dataResponse = ""
    while ($stream.DataAvailable) {
        $dataResponse += $reader.ReadLine() + "`n"
        Start-Sleep -Milliseconds 100
    }
    Write-Host "<<< $($dataResponse.Trim())" -ForegroundColor Green
    Write-Host ""

    # --- [7] QUIT ---
    Write-Host "[7] Sending QUIT:" -ForegroundColor Cyan
    $null = Send-SMTPCommand -Stream $stream -Reader $reader -Command "QUIT"
    Write-Host ""

    # --- Result Summary ---
    Write-Host "============================================" -ForegroundColor Cyan
    if ($rcptResponse -match "^250") {
        Write-Host " RESULT: SUCCESS - Port 25 is OPEN and relay accepted the recipient." -ForegroundColor Green
    } elseif ($rcptResponse -match "^550|^551|^552|^553|^554") {
        Write-Host " RESULT: RELAY REJECTED recipient (relay restriction or policy)." -ForegroundColor Red
        Write-Host "         Response: $($rcptResponse.Trim())" -ForegroundColor Red
    } else {
        Write-Host " RESULT: Port 25 is OPEN. Review responses above for details." -ForegroundColor Yellow
    }
    Write-Host "============================================" -ForegroundColor Cyan

    $reader.Close()
    $stream.Close()
    $tcpClient.Close()

} catch [System.Net.Sockets.SocketException] {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host " RESULT: FAILED - Could not connect to $MXRelay on port $Port" -ForegroundColor Red
    Write-Host " Error  : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host " Port 25 may be BLOCKED by a firewall or the host is unreachable." -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
} catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host " RESULT: ERROR during SMTP conversation"     -ForegroundColor Red
    Write-Host " Error  : $($_.Exception.Message)"          -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
}
