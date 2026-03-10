<#
.SYNOPSIS
    Creates a Mail Flow rule in Exchange Online to automatically encrypt messages containing "Secure" in the subject line.

.DESCRIPTION
    This script creates a New-TransportRule that monitors outbound and internal mail. 
    When the keyword "Secure" is detected in the subject, the "Encrypt" template 
    is applied automatically by the server.

.NOTES
    - PREREQUISITE MODULES: Requires 'ExchangeOnlineManagement' V3.
    - CUSTOMIZATION: 
        1. Change the '-Name' parameter to identify the rule in the Exchange Admin Center.
        2. Change '-SubjectContainsWords' to your preferred trigger (e.g., "[SECURE]", "PRIVATE").
    - LICENSING: The sender must have a license including Purview/AIP (M365 Business Premium, E3, or E5).
    - PREREQUISITE SETUP: Azure RMS must be active for the template to apply.
    - AUTHOR: Adapted for VisualFusion Environment.
#>

# Ensure you are connected before running
# Connect-ExchangeOnline

# Create the Rule
# Modify -Name and -SubjectContainsWords as needed for your specific policy.
New-TransportRule -Name "Encrypt Subject: Secure" `
    -SubjectContainsWords "Secure" `
    -ApplyRightsProtectionTemplate "Encrypt" `
    -StopRuleProcessing $true `
    -Enabled $true
