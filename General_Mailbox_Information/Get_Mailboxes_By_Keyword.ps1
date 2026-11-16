<#
.SYNOPSIS
    Lists the primary email address of User (licensed) and Shared mailboxes in Microsoft 365
    that match a keyword. Leave the keyword off to list all of them.

.DESCRIPTION
    Searches display names, aliases, primary SMTP addresses and all proxy addresses.
    Outputs one row per matching mailbox (primary email only) and exports to CSV.

.PARAMETER Keyword
    Text to search for (e.g. "sales", "support", "finance"). Wildcards are added automatically.
    If omitted, all user and shared mailboxes are listed.

.PARAMETER Type
    Which mailboxes to include: All (default), Licensed, or Shared.

.PARAMETER OutputPath
    CSV export path. Defaults to a timestamped file in the current folder.

.REQUIREMENTS
    Install-Module ExchangeOnlineManagement   (v3.x)
    Exchange Online permissions to read mailboxes (e.g. View-Only Recipients)

.EXAMPLE
    .\Get_Mailboxes_By_Keyword.ps1 -Keyword "sales"
    .\Get_Mailboxes_By_Keyword.ps1 -Keyword "support" -Type Shared
    .\Get_Mailboxes_By_Keyword.ps1                      # lists everything
    .\Get_Mailboxes_By_Keyword.ps1 -Keyword "hr" -OutputPath "C:\Temp\HR.csv"
#>

[CmdletBinding()]
param(
    [string]$Keyword = "",
    [ValidateSet("All", "Licensed", "Shared")]
    [string]$Type = "All",
    [string]$OutputPath = ".\Mailboxes_$(Get-Date -Format 'yyyyMMdd_HHmm').csv"
)

# Windows PowerShell 5.1 often defaults to older TLS, which causes
# "The underlying connection was closed" errors. Force TLS 1.2.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Connect if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Connected' })) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$recipientTypes = switch ($Type) {
    "Licensed" { @("UserMailbox") }
    "Shared"   { @("SharedMailbox") }
    default    { @("UserMailbox", "SharedMailbox") }
}

# Build a server-side filter so only matching mailboxes come back
$params = @{
    RecipientTypeDetails = $recipientTypes
    ResultSize           = "Unlimited"
    ErrorAction          = "Stop"
}
if ($Keyword) {
    $params.Filter = "Alias -like '*$Keyword*' -or DisplayName -like '*$Keyword*' -or PrimarySmtpAddress -like '*$Keyword*' -or EmailAddresses -like '*$Keyword*'"
    Write-Host "Retrieving $Type mailboxes matching '$Keyword'..." -ForegroundColor Cyan
}
else {
    Write-Host "Retrieving all $Type mailboxes..." -ForegroundColor Cyan
}

try {
    $mailboxes = Get-EXOMailbox @params -Properties EmailAddresses, RecipientTypeDetails, DisplayName, Alias, PrimarySmtpAddress
}
catch {
    Write-Warning "Get-EXOMailbox failed ($($_.Exception.Message)). Falling back to Get-Mailbox..."
    try {
        $mailboxes = Get-Mailbox @params
    }
    catch {
        Write-Error "Could not retrieve mailboxes: $($_.Exception.Message)"
        return
    }
}

$results = foreach ($mbx in $mailboxes) {
    [PSCustomObject]@{
        DisplayName        = $mbx.DisplayName
        MailboxType        = if ($mbx.RecipientTypeDetails -eq 'SharedMailbox') { 'Shared' } else { 'Licensed (User)' }
        PrimarySmtpAddress = $mbx.PrimarySmtpAddress
    }
}

$results = $results | Sort-Object MailboxType, DisplayName

if ($results) {
    $results | Format-Table -AutoSize
    $results | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "`nFound $(@($results).Count) mailbox(es)." -ForegroundColor Green
    Write-Host "Exported to: $OutputPath" -ForegroundColor Green
}
else {
    Write-Host "No mailboxes found$(if ($Keyword) { " matching '$Keyword'" })." -ForegroundColor Yellow
}

# Optional: disconnect when finished
# Disconnect-ExchangeOnline -Confirm:$false
