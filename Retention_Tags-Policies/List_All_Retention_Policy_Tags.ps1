<#
.SYNOPSIS
Lists all Retention Policy Tags in Microsoft 365 with key details in a table format.

.DESCRIPTION
This cmdlet retrieves all Retention Policy Tags configured in your Exchange Online environment 
and displays them in a table including the tag name, type, retention action, and age limit for retention. 
This helps administrators quickly audit retention tags and verify their settings.

.NOTES
Required Module:
    - Exchange Online PowerShell (EXO V2)
      Install-Module ExchangeOnlineManagement

Additional Notes:
    - Displays both default and custom retention tags.
    - Useful for reviewing tag names, their type (Default, Personal, etc.), retention action (MoveToArchive, Delete, etc.), 
      and age limits before linking them to Retention Policies.
    - Requires Exchange Online administrative permissions.
#>

Get-RetentionPolicyTag | Format-Table Name, Type, RetentionAction, AgeLimitForRetention
