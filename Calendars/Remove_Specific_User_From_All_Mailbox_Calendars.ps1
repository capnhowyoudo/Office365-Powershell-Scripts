<#
.SYNOPSIS
Removes a delegate from all user calendars in Exchange Online.

.DESCRIPTION
This script loops through all mailboxes in the organization and removes a specified delegate
from their calendars. It uses the `Get-MailboxFolderPermission` and `Remove-MailboxFolderPermission`
cmdlets. The `-WhatIf` switch is included by default to show what would happen without making changes.

.NOTES
• Replace `$DelegateUserUPN` with the delegate's email address you want to remove.
• Remove `-WhatIf` to actually apply the changes.
• Ensure you are connected to Exchange Online before running the script:
  Connect-ExchangeOnline -UserPrincipalName admin@yourdomain.com
• Handles errors gracefully and continues with remaining mailboxes.
#>

# ---------------- Variables ----------------
$DelegateUserUPN = "USER_EMAIL_TO_REMOVE@yourdomain.com"

# ---------------- Script ----------------
Get-Mailbox -ResultSize Unlimited | ForEach-Object {
    $CalendarIdentity = "$($_.PrimarySmtpAddress):\Calendar"
    try {
        Get-MailboxFolderPermission -Identity $CalendarIdentity -User $DelegateUserUPN -ErrorAction SilentlyContinue |
        Where-Object { $_.User.ToString() -eq $DelegateUserUPN } |
        Remove-MailboxFolderPermission -Identity $CalendarIdentity -User $DelegateUserUPN -Confirm:$false -WhatIf
    }
    catch {
        Write-Warning "Could not process calendar for $($_.PrimarySmtpAddress): $($_.Exception.Message)"
    }
}
