#Requires -Modules ExchangeOnlineManagement
<#
.SYNOPSIS
    Creates an MRM retention policy and links existing retention tags.

.DESCRIPTION
    Assumes all retention tags already exist. This script connects to Exchange Online,
    then creates (or updates) the retention policy defined in the $policyName variable
    with the following pre-existing tags linked to it:
      - 1 Month Delete
      - 1 Week Delete
      - 1 Year Delete
      - 5 Year Delete
      - 6 Month Delete
      - Default 2 year move to archive
      - Junk Email
      - Never Delete
      - Personal 1 year move to archive
      - Personal 5 year move to archive
      - Personal never move to archive
      - Recoverable Items 14 days move to archive

.NOTES
    Requires the ExchangeOnlineManagement module and the Compliance Management
    or Organization Management role.

    This policy mirrors the Default MRM Policy included with Exchange Online,
    applying archive and deletion settings to standard mailbox folders.

.EXAMPLE
    .\Create-RetentionPolicy.ps1
    .\Create-RetentionPolicy.ps1 -Disconnect
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [switch]$Disconnect
)

# ─────────────────────────────────────────────
# CONFIGURATION — change the policy name here
# ─────────────────────────────────────────────
$policyName = "Your Policy Name Here"

# ─────────────────────────────────────────────
# Connect to Exchange Online
# ─────────────────────────────────────────────
Write-Host "`nConnecting to Exchange Online..." -ForegroundColor Cyan
try {
    Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
    Write-Host "Connected successfully.`n" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to Exchange Online: $_"
    exit 1
}

# ─────────────────────────────────────────────
# Tag names to link (must already exist)
# ─────────────────────────────────────────────
$tagNames = @(
    "1 Month Delete"
    "1 Week Delete"
    "1 Year Delete"
    "5 Year Delete"
    "6 Month Delete"
    "Default 2 year move to archive"
    "Junk Email"
    "Never Delete"
    "Personal 1 year move to archive"
    "Personal 5 year move to archive"
    "Recoverable Items 14 days move to archive"
)

# ─────────────────────────────────────────────
# Verify all tags exist before proceeding
# ─────────────────────────────────────────────
Write-Host "Verifying retention tags exist..." -ForegroundColor Cyan
$missingTags = @()

foreach ($name in $tagNames) {
    $found = Get-RetentionPolicyTag -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $name }
    if ($found) {
        Write-Host "  [OK]   Found: '$name'" -ForegroundColor Green
    } else {
        Write-Host "  [MISS] Not found: '$name'" -ForegroundColor Red
        $missingTags += $name
    }
}

if ($missingTags.Count -gt 0) {
    Write-Warning "`nThe following tags were not found and cannot be linked:"
    $missingTags | ForEach-Object { Write-Warning "  - $_" }
    Write-Warning "Please create the missing tags and re-run the script, or remove them from the list."
    exit 1
}

# ─────────────────────────────────────────────
# Create or update the retention policy
# ─────────────────────────────────────────────
Write-Host "`nChecking for existing retention policy '$policyName'..." -ForegroundColor Cyan
$existingPolicy = Get-RetentionPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $policyName }

if ($existingPolicy) {
    Write-Host "  [FOUND] Policy already exists. Updating tag links..." -ForegroundColor Yellow
    try {
        Set-RetentionPolicy -Identity $policyName -RetentionPolicyTagLinks $tagNames -ErrorAction Stop
        Write-Host "  [OK]   Policy updated successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "  [ERR]  Failed to update policy: $_"
        exit 1
    }
}
else {
    Write-Host "  [NEW]  Creating policy '$policyName'..." -ForegroundColor Cyan
    try {
        New-RetentionPolicy `
            -Name $policyName `
            -RetentionPolicyTagLinks $tagNames `
            -ErrorAction Stop | Out-Null
        Write-Host "  [OK]   Policy created successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "  [ERR]  Failed to create policy: $_"
        exit 1
    }
}

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
Write-Host "`n── Summary ──────────────────────────────────────" -ForegroundColor Cyan
Write-Host "Policy : $policyName"
Write-Host "Tags   :"
$tagNames | ForEach-Object { Write-Host "  • $_" }
Write-Host "─────────────────────────────────────────────────`n" -ForegroundColor Cyan

# ─────────────────────────────────────────────
# Optional disconnect
# ─────────────────────────────────────────────
if ($Disconnect) {
    Disconnect-ExchangeOnline -Confirm:$false
    Write-Host "Disconnected from Exchange Online." -ForegroundColor Gray
}
