<#
.SYNOPSIS
Displays the sender address exceptions for a specific Exchange transport rule.

.DESCRIPTION
This command retrieves a transport (mail flow) rule by its identity and shows
the list of addresses or domains that are exempt from the rule using the
`ExceptIfFromAddressContainsWords` property. The output is formatted in a
list for easier readability.

.NOTES
Generic example for viewing exceptions configured in a transport rule.
#>

# Retrieve the specified transport rule and display its sender exceptions
Get-TransportRule -Identity "RuleName@domain.com or Rule Name" | Select-Object Name, ExceptIfFromAddressContainsWords | Format-List
