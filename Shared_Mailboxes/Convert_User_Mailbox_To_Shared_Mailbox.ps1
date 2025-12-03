<#
.SYNOPSIS
Converts a user mailbox into a shared mailbox in Microsoft 365.

.DESCRIPTION
This command updates an existing user mailbox and changes its mailbox type to "Shared". 
Shared mailboxes do not require a license (unless they exceed size limits or need certain 
features). Once converted, the mailbox can be accessed by delegated users without assigning 
a license directly to the mailbox.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2) module.
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - Converting to a shared mailbox does not remove mailbox content.
    - The mailbox will remain assigned to the user until converted.
    - After conversion, you may assign Full Access, Send As, or Send On Behalf permissions 
      using the appropriate permission cmdlets.
#>

Set-Mailbox "user@example.com" -Type Shared
