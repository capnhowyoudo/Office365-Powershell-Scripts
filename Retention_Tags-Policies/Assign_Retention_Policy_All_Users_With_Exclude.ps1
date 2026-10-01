<#
.SYNOPSIS
    Assigns a retention policy (chosen at runtime, or passed via -PolicyName) to every
    mailbox EXCEPT the mailbox(es) you choose to exclude, and verifies the policy's
    purge tag is truly a Default Policy Tag.

#Requires -Modules ExchangeOnlineManagement

.DESCRIPTION
    Four things happen here, and they're deliberately kept distinct:

    0. POLICY SELECTION — if -PolicyName is not supplied on the command line, the
       script connects to Exchange Online, lists every available retention policy,
       and prompts you to pick one before doing anything else.

    0b. EXCLUSION SELECTION — if -ExcludedMailboxes is not supplied on the command
        line, the script prompts you to enter one or more mailboxes to exclude
        (email address, UPN, or alias; comma-separated for multiple).

    1. VALIDATION — confirms the chosen policy's purge tag has Type = All. Only a tag
       of Type "All" is a Default Policy Tag (DPT), meaning it applies automatically
       to every item that isn't otherwise tagged. Type is set at creation and cannot
       be changed afterward (Set-RetentionPolicyTag has no -Type parameter), so if the
       tag isn't already Type "All", the script stops before touching any mailbox
       rather than silently assigning a policy that won't actually auto-purge anything.
       Editing a policy's tag list in the EAC (checking/unchecking tags) does not change
       an existing tag's Type -- only linking happens there.

    2. ASSIGNMENT — assigns the chosen retention policy to every UserMailbox AND
       SharedMailbox EXCEPT the mailbox(es) you chose to exclude. Each excluded
       address is resolved and validated up front, so a typo there can't silently
       leave the wrong person unprotected.

.PARAMETER PolicyName
    Name of the retention policy to assign. If omitted, the script lists available
    retention policies and prompts you to choose one interactively.

.PARAMETER DpTagName
    Name of the tag expected to be the Default Policy Tag. If omitted, defaults to
    whatever $PolicyName ends up being (either passed in or chosen interactively).

.PARAMETER ExcludedMailboxes
    One or more mailbox identities (email address, UPN, or alias) to EXCLUDE from
    assignment. If omitted, the script prompts you to enter one or more (comma-
    separated) interactively.

.PARAMETER ExcludeSharedMailboxes
    Leaves shared mailboxes OUT of the assignment. By default, shared mailboxes ARE
    included along with user mailboxes.

.EXAMPLE
    .\Assign-RetentionPolicy-ExcludeMailboxes.ps1 -WhatIf
    Dry run: prompts you to pick a policy and enter mailbox(es) to exclude, then shows
    what would happen for all remaining user + shared mailboxes.

.EXAMPLE
    .\Assign-RetentionPolicy-ExcludeMailboxes.ps1
    Prompts for a policy and exclusion(s), then runs for real.

.EXAMPLE
    .\Assign-RetentionPolicy-ExcludeMailboxes.ps1 -PolicyName "Contoso 3-Year Purge" -ExcludedMailboxes "exec@contoso.com"
    Skips both prompts and runs directly with the values supplied.

.EXAMPLE
    .\Assign-RetentionPolicy-ExcludeMailboxes.ps1 -ExcludeSharedMailboxes
    Prompts for a policy and exclusion(s), real run, user mailboxes only (shared
    mailboxes left out entirely).
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param (
    [string]$PolicyName,
    [string]$DpTagName,

    # Leave unset to be prompted interactively.
    [string[]]$ExcludedMailboxes,

    # Shared mailboxes are included by default. Pass this switch to leave them out instead.
    [switch]$ExcludeSharedMailboxes
)

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
# Prompt for the retention policy if not supplied
# ─────────────────────────────────────────────
if ([string]::IsNullOrWhiteSpace($PolicyName)) {
    Write-Host "No -PolicyName supplied. Retrieving available retention policies..." -ForegroundColor Cyan
    $availablePolicies = Get-RetentionPolicy -ErrorAction SilentlyContinue | Sort-Object Name

    if (-not $availablePolicies -or $availablePolicies.Count -eq 0) {
        Write-Error "No retention policies were found in the organization. Nothing to choose from."
        exit 1
    }

    Write-Host "`nAvailable retention policies:" -ForegroundColor Green
    for ($idx = 0; $idx -lt $availablePolicies.Count; $idx++) {
        Write-Host ("  [{0}] {1}" -f ($idx + 1), $availablePolicies[$idx].Name)
    }

    do {
        $selection = Read-Host "`nEnter the number of the policy to assign (or type the exact policy name)"

        $chosen = $null
        $asInt = 0
        if ([int]::TryParse($selection, [ref]$asInt) -and $asInt -ge 1 -and $asInt -le $availablePolicies.Count) {
            $chosen = $availablePolicies[$asInt - 1]
        }
        else {
            $chosen = $availablePolicies | Where-Object { $_.Name -eq $selection }
        }

        if (-not $chosen) {
            Write-Warning "'$selection' isn't a valid number or policy name. Try again."
        }
    } while (-not $chosen)

    $PolicyName = $chosen.Name
    Write-Host "  [OK] Selected policy: $PolicyName" -ForegroundColor Green
}

# DpTagName defaults to whatever policy name we ended up with, unless explicitly passed.
if ([string]::IsNullOrWhiteSpace($DpTagName)) {
    $DpTagName = $PolicyName
}

# ─────────────────────────────────────────────
# Prompt for mailbox(es) to exclude if not supplied
# ─────────────────────────────────────────────
if (-not $ExcludedMailboxes -or $ExcludedMailboxes.Count -eq 0) {
    do {
        $exclInput = Read-Host "`nEnter mailbox(es) to exclude -- email address, UPN, or alias (comma-separated for multiple)"
        $parsed = $exclInput -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

        if (-not $parsed -or $parsed.Count -eq 0) {
            Write-Warning "You must enter at least one mailbox to exclude. Try again."
        }
    } while (-not $parsed -or $parsed.Count -eq 0)

    $ExcludedMailboxes = $parsed
}

# ─────────────────────────────────────────────
# Resolve and validate excluded mailbox(es) up front
# ─────────────────────────────────────────────
Write-Host "`nValidating excluded mailbox(es)..." -ForegroundColor Cyan
$excludedResolved = @()
foreach ($addr in $ExcludedMailboxes) {
    $m = Get-EXOMailbox -Identity $addr -ErrorAction SilentlyContinue
    if (-not $m) {
        Write-Error "Excluded mailbox '$addr' could not be resolved. Fix this before running -- if it doesn't exist, this exclusion would silently do nothing."
        exit 1
    }
    Write-Host "  [OK] Will exclude: $($m.PrimarySmtpAddress)" -ForegroundColor Yellow
    $excludedResolved += $m.PrimarySmtpAddress.ToLower()
}

# ─────────────────────────────────────────────
# Verify the retention policy exists
# ─────────────────────────────────────────────
Write-Host "`nChecking retention policy '$PolicyName'..." -ForegroundColor Cyan
$policy = Get-RetentionPolicy -Identity $PolicyName -ErrorAction SilentlyContinue
if (-not $policy) {
    Write-Error "Retention policy '$PolicyName' was not found."
    exit 1
}
Write-Host "  [OK] Policy found. Linked tags:" -ForegroundColor Green
$policy.RetentionPolicyTagLinks | ForEach-Object { Write-Host "    • $_" }

# ─────────────────────────────────────────────
# Verify the purge tag is actually a Default Policy Tag (Type = All)
# ─────────────────────────────────────────────
Write-Host "`nChecking tag '$DpTagName' configuration..." -ForegroundColor Cyan
$tag = Get-RetentionPolicyTag -Identity $DpTagName -ErrorAction SilentlyContinue

if (-not $tag) {
    Write-Error "Tag '$DpTagName' was not found."
    exit 1
}

Write-Host ("  Name              : {0}" -f $tag.Name)
Write-Host ("  Type              : {0}" -f $tag.Type)
Write-Host ("  RetentionAction   : {0}" -f $tag.RetentionAction)
Write-Host ("  AgeLimitForRetention (days): {0}" -f $tag.AgeLimitForRetention)
Write-Host ("  RetentionEnabled  : {0}" -f $tag.RetentionEnabled)

if ($tag.Type -ne 'All') {
    Write-Warning "`n'$DpTagName' has Type = '$($tag.Type)', NOT 'All'."
    Write-Warning "It is NOT a Default Policy Tag and will not purge anything automatically -- only items a user manually tags would be affected."
    Write-Warning "Type can't be changed after creation. To get true automatic default behavior, create a NEW tag of Type 'All', e.g.:"
    Write-Warning "  New-RetentionPolicyTag `"$DpTagName-Default`" -Type All -RetentionEnabled `$true -AgeLimitForRetention $($tag.AgeLimitForRetention) -RetentionAction $($tag.RetentionAction)"
    Write-Warning "...then append it to the policy's RetentionPolicyTagLinks (don't replace the existing list)."
    Write-Warning "`nStopping here rather than assigning the policy org-wide under a false assumption."
    exit 1
}

Write-Host "  [OK] This is a true Default Policy Tag (Type = All) -- it will apply automatically to untagged items." -ForegroundColor Green

# ─────────────────────────────────────────────
# Build mailbox scope, minus exclusions
# ─────────────────────────────────────────────
$recipientTypes = @('UserMailbox')
if (-not $ExcludeSharedMailboxes) { $recipientTypes += 'SharedMailbox' }

Write-Host "`nRetrieving mailboxes (types: $($recipientTypes -join ', '))..." -ForegroundColor Cyan
$allMailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails $recipientTypes -ErrorAction Stop

$mailboxes = $allMailboxes | Where-Object { $excludedResolved -notcontains $_.PrimarySmtpAddress.ToLower() }
$excludedCount = $allMailboxes.Count - $mailboxes.Count

Write-Host "  Found $($allMailboxes.Count) mailbox(es) total." -ForegroundColor Green
Write-Host "  Excluding $excludedCount mailbox(es): $($excludedResolved -join ', ')" -ForegroundColor Yellow
Write-Host "  Will process $($mailboxes.Count) mailbox(es).`n" -ForegroundColor Green

if ($mailboxes.Count -eq 0) {
    Write-Warning "No mailboxes left to process after exclusions. Nothing to do."
    exit 0
}

# ─────────────────────────────────────────────
# Assign the retention policy
# ─────────────────────────────────────────────
$success = @()
$failed  = @()
$skipped = @()
$i = 0

foreach ($mbx in $mailboxes) {
    $i++
    Write-Progress -Activity "Assigning retention policy" -Status "$($mbx.PrimarySmtpAddress) ($i of $($mailboxes.Count))" -PercentComplete (($i / $mailboxes.Count) * 100)

    if ($mbx.RetentionPolicy -eq $PolicyName) {
        $skipped += $mbx.PrimarySmtpAddress
        continue
    }

    $target = $mbx.PrimarySmtpAddress
    if ($PSCmdlet.ShouldProcess($target, "Set-Mailbox -RetentionPolicy '$PolicyName'")) {
        try {
            Set-Mailbox -Identity $mbx.Identity -RetentionPolicy $PolicyName -ErrorAction Stop
            $success += $target
        }
        catch {
            Write-Warning "  [ERR] $target : $_"
            $failed += $target
        }
    }
}
Write-Progress -Activity "Assigning retention policy" -Completed

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
Write-Host "`n── Summary ──────────────────────────────────────" -ForegroundColor Cyan
Write-Host "Policy            : $PolicyName"
Write-Host "DPT verified      : $DpTagName (Type=All)"
Write-Host "Scope             : $($recipientTypes -join ', ')"
Write-Host "Excluded          : $($excludedResolved -join ', ')"
Write-Host "Newly assigned    : $($success.Count)"
Write-Host "Already assigned  : $($skipped.Count)"
Write-Host "Failed            : $($failed.Count)"
if ($failed.Count -gt 0) {
    Write-Host "Failed mailboxes:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  • $_" }
}
Write-Host "─────────────────────────────────────────────────`n" -ForegroundColor Cyan
