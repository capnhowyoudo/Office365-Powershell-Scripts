<#
.SYNOPSIS
Retrieves a specific Exchange transport rule by identity.

.DESCRIPTION
This command queries Exchange to display details of a single transport (mail flow) rule
specified by its identity. It shows properties such as the rule's name, state, priority,
and mode, allowing administrators to inspect or troubleshoot a particular rule.

.NOTES
Generic example for retrieving a specific transport rule.
#>

# Retrieve the transport rule with the specified identity
Get-TransportRule -Identity "Rule name or email"
