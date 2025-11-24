<#
.SYNOPSIS
Removes a specified delegate user's mailbox permissions in Exchange Online.

.DESCRIPTION
This script processes all mailboxes in Exchange Online and removes the specified delegate's access rights (FullAccess, SendAs, etc.) from each mailbox.
- Supports dry run mode using the $WhatIfMode variable.
- Can skip connection prompt if already connected to Exchange Online.
- Can process all mailboxes or a limited number specified by $ResultSize.
- Provides progress updates for each mailbox being processed.

.NOTES
- Replace $DelegateUserUPN with the generic or target email (e.g., user@domain.com).
- $WhatIfMode = $true performs a dry run without making changes.
- $WhatIfMode = $false executes the removal.
- Example: Remove FullAccess permission for a delegate from all mailboxes.
- Reference: Exchange Online PowerShell documentation.

.VARIABLES
$DelegateUserUPN       - Email of delegate to remove (e.g., user@domain.com)
$ResultSize            - Number of mailboxes to process ('Unlimited' for all)
$AccessRightToRemove   - Permission to remove ('FullAccess', 'SendAs', etc.)
$SkipConnectionCheck   - Skip Exchange Online connection if already connected
$WhatIfMode            - Run in dry run mode if $true
#>

# 1. Configuration
$DelegateUserUPN = "user@domain.com"
$ResultSize = "Unlimited"
$AccessRightToRemove = "FullAccess"
$SkipConnectionCheck = $false
$WhatIfMode = $true

# 2. Connect to Exchange Online
try {
    if (-not $SkipConnectionCheck -and -not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' -and $_.State -eq 'Opened' })) {
        Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
        Connect-ExchangeOnline 
    }
}
catch {
    Write-Error "Failed to connect to Exchange Online. Please check the module and your credentials."
    exit
}

# 3. Process Mailboxes and Remove Permission
Write-Host "Starting removal process for '$DelegateUserUPN' with '$AccessRightToRemove' permission." -ForegroundColor Yellow

$Mailboxes = Get-Mailbox -ResultSize $ResultSize -ErrorAction Stop
$Count = 0
$Total = $Mailboxes.Count

foreach ($Mailbox in $Mailboxes) {
    $Count++
    $MailboxIdentity = $Mailbox.PrimarySmtpAddress
    Write-Host "($Count/$Total) Checking mailbox: $($Mailbox.DisplayName) ($MailboxIdentity)..." -NoNewline

    try {
        $PermissionExists = Get-MailboxPermission -Identity $MailboxIdentity -User $DelegateUserUPN -ErrorAction SilentlyContinue |
                            Where-Object { $_.AccessRights -contains $AccessRightToRemove -and $_.IsInherited -eq $false }

        if ($PermissionExists) {
            Write-Host " Permission found. Removing..." -ForegroundColor Red

            $RemoveParams = @{
                Identity        = $MailboxIdentity
                User            = $DelegateUserUPN
                AccessRights    = $AccessRightToRemove
                InheritanceType = "All"
                Confirm         = $false
            }

            if ($WhatIfMode) {
                $RemoveParams.Add("WhatIf", $true)
                Write-Host " (Dry Run) Command to execute: Remove-MailboxPermission @RemoveParams" -ForegroundColor DarkYellow
            }

            Remove-MailboxPermission @RemoveParams -ErrorAction Stop
            
            if (-not $WhatIfMode) {
                Write-Host " ✅ Removed $AccessRightToRemove for $DelegateUserUPN from $MailboxIdentity." -ForegroundColor Green
            }
        } else {
            Write-Host " No $AccessRightToRemove permission found." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Error "An error occurred while processing mailbox $($Mailbox.DisplayName): $($_.Exception.Message)"
    }
}

# 4. Completion
Write-Host "Script finished. Review the output." -ForegroundColor Yellow
if ($WhatIfMode) {
    Write-Host "REMINDER: This was a DRY RUN (-WhatIf). No actual changes were made." -ForegroundColor Yellow
    Write-Host "Set the 'WhatIfMode' variable to '$false' to execute the changes." -ForegroundColor Yellow
}
