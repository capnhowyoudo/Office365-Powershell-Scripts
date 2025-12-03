<#
.SYNOPSIS
Displays all retention tags linked to a specific retention policy in Microsoft 365.

.DESCRIPTION
This command retrieves the RetentionPolicy object by its name and lists all the Retention Policy Tags
associated with that policy. The output shows the names of the tags in a table format, which can be
used to verify or document the retention policy configuration.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install using: Install-Module ExchangeOnlineManagement

Additional Notes:
    - Replace "Contoso-Default-Retention-Policy" with the retention policy you want to check.
    - Use this command to verify which retention tags are applied to a policy before applying it
      to mailboxes.
    - You must have appropriate Exchange Online administrative permissions to view retention policies.
#>

(Get-RetentionPolicy "Default MRM Policy").RetentionPolicyTagLinks | Format-Table Name
