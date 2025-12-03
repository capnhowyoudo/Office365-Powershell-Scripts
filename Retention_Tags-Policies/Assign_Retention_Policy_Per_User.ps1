<#
.SYNOPSIS
Assigns a retention policy to a mailbox in Microsoft 365.

.DESCRIPTION
This cmdlet sets a specific Retention Policy for a mailbox. Retention Policies define how long 
items are retained, when they are moved to the archive, and when they are deleted. Assigning 
a retention policy ensures the mailbox follows organizational compliance and retention rules.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - The mailbox must exist in the organization before assigning a retention policy.
    - The retention policy specified must already exist.
    - Appropriate Exchange Online administrative permissions are required.
    - Use this cmdlet to enforce retention and compliance rules on specific mailboxes.

CMDLET
-------
# Assign the retention policy to the mailbox
# Example using generic placeholders:
Set-Mailbox "user@example.com" -RetentionPolicy "Finance-RetentionPolicy"
#>

Set-Mailbox "user@example.com" -RetentionPolicy "Finance-RetentionPolicy"
