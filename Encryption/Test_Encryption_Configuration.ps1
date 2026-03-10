<#
.SYNOPSIS
    Tests the Integrated Rights Management (IRM) configuration between a sender and a recipient.

.DESCRIPTION
    This command performs a comprehensive end-to-end test of the IRM pipeline. 
    It simulates the encryption process to verify that the tenant's backend 
    is correctly configured to issue licenses and templates.

.NOTES
    - PREREQUISITE: You must be connected to the Exchange Online module 
      using 'Connect-ExchangeOnline' before running this command.
    - RELEVANCE: This is the final verification step after setting up 
      AIPService and creating Mail Flow/Transport rules.
    - RECIPIENT: Using an external recipient address helps verify the 
      'Pre-licensing' and 'One-Time Passcode' (OTP) compatibility.
    - AUTHOR: Adapted for VisualFusion Environment.
#>

# 1. Ensure you are authenticated
# Connect-ExchangeOnline

# 2. Run the diagnostic test
# Replace with generic or specific test addresses as needed
Test-IRMConfiguration -Sender sender@yourdomain.com -Recipient recipient@external.com
