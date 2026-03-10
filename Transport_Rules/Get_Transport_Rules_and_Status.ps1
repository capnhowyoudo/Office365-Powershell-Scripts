<#
.SYNOPSIS
Retrieves Exchange transport rules and displays their status and priority.

.DESCRIPTION
This command queries Exchange for all transport (mail flow) rules in the organization.
It returns each rule’s name, state, priority, and mode. The results are sorted by
priority so administrators can review the order in which rules are processed.

.NOTES
Generic example for reviewing Exchange transport rules and their processing order.
#>

# Retrieve all transport rules and sort them by priority
Get-TransportRule | Select-Object Name, State, Priority, Mode | Sort-Object Priority
