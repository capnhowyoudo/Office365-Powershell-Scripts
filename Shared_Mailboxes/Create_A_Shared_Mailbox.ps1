<#
.SYNOPSIS
Creates a new shared mailbox in Microsoft 365.

.DESCRIPTION
This cmdlet creates a shared mailbox that multiple users can access and use for collaborative purposes.
Shared mailboxes do not require separate licenses (unless over mailbox size limits) and can be accessed
by users granted Full Access or other mailbox permissions.

.NOTES
- Required Module: Exchange Online PowerShell V2 module (ExchangeOnlineManagement)
- Replace "SharedMailboxName" with the display name of the shared mailbox.
- Replace "sharedmailbox@company.com" with the primary email address for the shared mailbox.
- After creation, assign permissions using Add-MailboxPermission or Set-Mailbox cmdlets as needed.
#>

New-Mailbox -Shared -Name "SharedMailboxName" -PrimarySmtpAddress sharedmailbox@company.com
