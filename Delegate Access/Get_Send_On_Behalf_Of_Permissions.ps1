<#
.SYNOPSIS
    Displays users who have Send on Behalf permission for a mailbox.

.DESCRIPTION
    Retrieves the Send on Behalf delegates configured on the specified
    Exchange Online or on-premises Exchange mailbox.

.NOTES
    Requires the Exchange Management Shell or an active Exchange Online
    PowerShell session with the appropriate permissions.
#>

Get-Mailbox -Identity "sales@contoso.com" | Select-Object -ExpandProperty GrantSendOnBehalfTo
