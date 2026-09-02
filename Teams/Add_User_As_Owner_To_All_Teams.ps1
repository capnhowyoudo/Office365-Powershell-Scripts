<#
.SYNOPSIS
    Adds a specified user as Owner to all Microsoft Teams the tenant has,
    including as Owner of every private/shared channel within those teams.

.DESCRIPTION
    Standard ("regular") channels in Microsoft Teams do NOT have their own
    owner list — ownership is a Team-level property. Only Private and Shared
    channels have their own separate owner/member lists. This script:

      1. Adds the target user as Owner on every Team in the tenant.
      2. Optionally also adds the user as Owner on every Private/Shared
         channel within those teams (since those need to be set separately).

    Requires the MicrosoftTeams PowerShell module.

.PARAMETER UserPrincipalName
    The UPN (email) of the user to add as owner, e.g. jane.doe@contoso.com

.PARAMETER IncludePrivateChannels
    Switch. If set, also adds the user as owner to all private/shared
    channels (not just the parent teams).

.PARAMETER WhatIf
    Switch. If set, only reports what WOULD be changed, without making changes.

.EXAMPLE
    .\Add_User_As_Owner_To_All_Teams.ps1 -UserPrincipalName jane.doe@contoso.com

.EXAMPLE
    .\Add_User_As_Owner_To_All_Teams.ps1 -UserPrincipalName jane.doe@contoso.com -IncludePrivateChannels

.EXAMPLE
    .\Add_User_As_Owner_To_All_Teams.ps1 -UserPrincipalName jane.doe@contoso.com -WhatIf

.NOTES
    - You must be a Global Admin or Teams Admin to run this against all teams.
    - Adding someone as owner of hundreds/thousands of teams can trigger
      throttling — the script includes a small delay and retry logic.
    - Run Connect-MicrosoftTeams first, or let the script prompt you.

    If you see an error like:
        "File C:\Path\To\Add_User_As_Owner_To_All_Teams.ps1 cannot be loaded.
        The file ... is not digitally signed. You cannot run this script on
        the current system."

    This is Windows' execution policy blocking unsigned scripts. Fix it with
    one of the following (in order of preference):

    Option 1 — Unblock just this file (recommended, safest):
        Unblock-File -Path "C:\Path\To\Add_User_As_Owner_To_All_Teams.ps1"
        Downloaded files get an "internet zone" flag that triggers this
        error; unblocking removes the flag without changing any policy.

    Option 2 — Temporarily bypass policy for a single run:
        powershell -ExecutionPolicy Bypass -File "C:\Path\To\Add_User_As_Owner_To_All_Teams.ps1" -UserPrincipalName jane.doe@contoso.com
        This does not change any system setting; it only applies to that
        one launch.

    Option 3 — Change your user-level execution policy:
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
        Lets you run local/unblocked scripts going forward. Scripts
        downloaded from the internet still need to be unblocked (Option 1)
        unless signed. May require an elevated (admin) prompt depending on
        your machine's default policy.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [switch]$IncludePrivateChannels,

    [switch]$WhatIf
)

# ---------------------------------------------------------------------------
# 0. Pre-flight checks
# ---------------------------------------------------------------------------

if (-not (Get-Module -ListAvailable -Name MicrosoftTeams)) {
    Write-Host "MicrosoftTeams module not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name MicrosoftTeams -Force -Scope CurrentUser -AllowClobber
}

Import-Module MicrosoftTeams -ErrorAction Stop

try {
    # This will no-op if already connected
    $null = Get-CsOnlineUser -Identity $UserPrincipalName -ErrorAction Stop
}
catch {
    Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
    Connect-MicrosoftTeams | Out-Null
}

# ---------------------------------------------------------------------------
# 1. Get all teams in the tenant
# ---------------------------------------------------------------------------

Write-Host "Fetching all teams in the tenant..." -ForegroundColor Cyan
$allTeams = Get-Team

if (-not $allTeams -or $allTeams.Count -eq 0) {
    Write-Warning "No teams found. Check your permissions or connection."
    return
}

Write-Host "Found $($allTeams.Count) teams." -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2. Helper: retry wrapper for throttling-prone calls
# ---------------------------------------------------------------------------

function Invoke-WithRetry {
    param(
        [scriptblock]$Action,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 5
    )
    $attempt = 0
    while ($attempt -lt $MaxRetries) {
        try {
            & $Action
            return $true
        }
        catch {
            $attempt++
            if ($attempt -ge $MaxRetries) {
                Write-Warning "  Failed after $MaxRetries attempts: $($_.Exception.Message)"
                return $false
            }
            Start-Sleep -Seconds ($DelaySeconds * $attempt)
        }
    }
}

# ---------------------------------------------------------------------------
# 3. Add user as Owner to every Team
# ---------------------------------------------------------------------------

$results = @()
$counter = 0

foreach ($team in $allTeams) {
    $counter++
    Write-Progress -Activity "Adding owner to teams" -Status "$($team.DisplayName)" `
        -PercentComplete (($counter / $allTeams.Count) * 100)

    $existingOwner = $false
    try {
        $currentUsers = Get-TeamUser -GroupId $team.GroupId -Role Owner -ErrorAction Stop
        $existingOwner = $currentUsers.User -contains $UserPrincipalName
    }
    catch {
        Write-Warning "Could not read owners for '$($team.DisplayName)': $($_.Exception.Message)"
    }

    if ($existingOwner) {
        $results += [pscustomobject]@{
            Team   = $team.DisplayName
            Scope  = "Team"
            Status = "AlreadyOwner"
        }
        continue
    }

    if ($WhatIf) {
        Write-Host "[WhatIf] Would add $UserPrincipalName as Owner of team '$($team.DisplayName)'" -ForegroundColor Yellow
        $results += [pscustomobject]@{ Team = $team.DisplayName; Scope = "Team"; Status = "WouldAdd" }
        continue
    }

    $ok = Invoke-WithRetry -Action {
        Add-TeamUser -GroupId $team.GroupId -User $UserPrincipalName -Role Owner -ErrorAction Stop
    }

    $results += [pscustomobject]@{
        Team   = $team.DisplayName
        Scope  = "Team"
        Status = if ($ok) { "Added" } else { "Failed" }
    }

    Start-Sleep -Milliseconds 500  # be gentle on throttling
}

# ---------------------------------------------------------------------------
# 4. Optionally add user as Owner to every Private/Shared channel
# ---------------------------------------------------------------------------

if ($IncludePrivateChannels) {
    Write-Host "`nProcessing private/shared channels..." -ForegroundColor Cyan

    foreach ($team in $allTeams) {
        $channels = Get-TeamChannel -GroupId $team.GroupId | Where-Object {
            $_.MembershipType -eq "Private" -or $_.MembershipType -eq "Shared"
        }

        foreach ($channel in $channels) {
            try {
                $currentChannelOwners = Get-TeamChannelUser -GroupId $team.GroupId `
                    -DisplayName $channel.DisplayName -Role Owner -ErrorAction Stop
                $alreadyOwner = $currentChannelOwners.User -contains $UserPrincipalName
            }
            catch {
                $alreadyOwner = $false
            }

            if ($alreadyOwner) {
                $results += [pscustomobject]@{
                    Team   = $team.DisplayName
                    Scope  = "Channel: $($channel.DisplayName)"
                    Status = "AlreadyOwner"
                }
                continue
            }

            if ($WhatIf) {
                Write-Host "[WhatIf] Would add $UserPrincipalName as Owner of channel '$($channel.DisplayName)' in '$($team.DisplayName)'" -ForegroundColor Yellow
                $results += [pscustomobject]@{
                    Team = $team.DisplayName; Scope = "Channel: $($channel.DisplayName)"; Status = "WouldAdd"
                }
                continue
            }

            $ok = Invoke-WithRetry -Action {
                Add-TeamChannelUser -GroupId $team.GroupId -DisplayName $channel.DisplayName `
                    -User $UserPrincipalName -Role Owner -ErrorAction Stop
            }

            $results += [pscustomobject]@{
                Team   = $team.DisplayName
                Scope  = "Channel: $($channel.DisplayName)"
                Status = if ($ok) { "Added" } else { "Failed" }
            }

            Start-Sleep -Milliseconds 500
        }
    }
}

# ---------------------------------------------------------------------------
# 5. Report
# ---------------------------------------------------------------------------

Write-Host "`n===== Summary =====" -ForegroundColor Cyan
$results | Group-Object Status | ForEach-Object {
    Write-Host "$($_.Name): $($_.Count)"
}

$outFile = ".\AddOwnerResults_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$results | Export-Csv -Path $outFile -NoTypeInformation
Write-Host "`nFull results exported to $outFile" -ForegroundColor Green
