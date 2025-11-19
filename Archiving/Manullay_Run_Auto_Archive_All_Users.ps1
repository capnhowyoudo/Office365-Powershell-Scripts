<#
.SYNOPSIS
Runs the Managed Folder Assistant (MFA) on all user mailboxes.

.NOTES
Applies retention policy processing to all user mailboxes.
#>

Get-Mailbox -Filter {RecipientTypeDetails -eq 'UserMailbox'} | ForEach-Object { Start-ManagedFolderAssistant $_.Identity }
