<#
.SYNOPSIS
Modifies an existing Exchange transport rule to add exceptions for specific sender addresses.

.DESCRIPTION
This command updates the transport (mail flow) rule identified by its name or identity.
It configures the rule to **exclude messages from specific sender addresses** by using
the `-ExceptIfFromAddressContainsWords` parameter. This ensures the rule does not
apply to emails from the specified domains or addresses.

.NOTES
Generic example for adding sender exceptions to a transport rule.
#>

# Add sender address exceptions to a transport rule using generic email addresses
Set-TransportRule -Identity "RuleName@domain.com or rulename" -ExceptIfFromAddressContainsWords "domain1.com", "user1@domain.com", "user2@domain.com"
