<#
.SYNOPSIS
Filters Exchange transport rules by a specific keyword in their description.

.DESCRIPTION
This command queries all Exchange transport (mail flow) rules and filters them
based on whether the description contains the specified keyword. The matching
rules are displayed in a detailed list format, showing only the rule’s name and
description. This is useful for quickly identifying rules related to a particular
process or update.

.NOTES
Generic example for searching transport rules by description keyword.
#>

# Filter transport rules containing a specific keyword in the description and display name and description
Get-TransportRule | Where-Object { $_.Description -like "*KeywordHere*" } | Format-List Name, Description
