 Gemini said

<# 
.SYNOPSIS Exports a list of specific recipient types from Exchange to a CSV file.

.DESCRIPTION This script retrieves all user mailboxes, shared mailboxes, and distribution groups (both universal and non-universal) from the environment. It captures the display name, primary SMTP address, and the specific recipient type detail, then saves the output to a local CSV file.

.NOTES - Date Created: 2026-02-09 - Requirements: Exchange Online Management module. - Permissions: Requires View-Only Recipients or higher permissions in Exchange. - Ensure the "C:\temp" directory exists before execution. 
#>

Get-Recipient -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox, MailUniversalDistributionGroup, MailNonUniversalGroup | Select-Object DisplayName, PrimarySmtpAddress, RecipientTypeDetails | Export-Csv -Path "C:\temp\AllRecipients.csv" -NoTypeInformation
