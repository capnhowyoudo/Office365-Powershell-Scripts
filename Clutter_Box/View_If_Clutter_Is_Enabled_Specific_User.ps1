<#
.SYNOPSIS
Retrieves the Clutter status for a specific user mailbox.

.DESCRIPTION
The Get-Clutter cmdlet displays whether Clutter is enabled or disabled
for a user in Exchange Online. This allows administrators to verify
the current mailbox Clutter configuration.

.NOTES
Always replace the sample email address with a valid user mailbox.
Requires an active Exchange Online PowerShell session.
#>

Get-Clutter -Identity "user@example.com"
