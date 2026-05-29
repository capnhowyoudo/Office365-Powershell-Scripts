<#
.SYNOPSIS
    Adds email addresses to the exception list of an Exchange Online transport rule.

.DESCRIPTION
    This script appends one or more sender email addresses to the ExceptIfFrom
    condition of a specified Exchange Online transport rule. It retrieves the
    existing exception list first to ensure no current entries are overwritten,
    then merges and applies the updated list. A confirmation of all exception
    senders is displayed upon completion.

    Existing exception senders and IP ranges are fully preserved. The script
    only passes the -ExceptIfFrom parameter to Set-TransportRule, leaving all
    other conditions such as ExceptIfSenderIpRanges and ExceptIfSubjectMatchesPatterns
    untouched. Only the new addresses are merged into the existing sender list,
    with duplicate checking to prevent any entries from being added more than once.

.NOTES
    Author       : capnhowyoudo
    Version      : 1.0
    Requirements : Exchange Online PowerShell module (Connect-ExchangeOnline)
                   Transport Rule management permissions
    Usage        : Update $ruleName to match your target rule.
                   Update $newAddresses with the emails you want to add.
                   Additional addresses can be added to the $newAddresses array.
                   Example: @("email1@domain.com", "email2@domain.com", "email3@domain.com")
#>

# Add new senders to the exception list for the spoofed internal sender rule
$ruleName = "Block Direct Send - Spoofed Internal Sender"

# Get current exception senders
$rule = Get-TransportRule -Identity $ruleName
$currentExceptFrom = $rule.ExceptIfFrom

# Add new addresses (avoids duplicates) - replace with desired email addresses
$newAddresses = @("email1@domain.com", "email2@domain.com")

$updatedExceptFrom = ($currentExceptFrom + $newAddresses) | Select-Object -Unique

# Apply the update
Set-TransportRule -Identity $ruleName -ExceptIfFrom $updatedExceptFrom

# Confirm
$updated = Get-TransportRule -Identity $ruleName
Write-Host "Updated ExceptIfFrom list:" -ForegroundColor Cyan
$updated.ExceptIfFrom | ForEach-Object { Write-Host "  - $_" -ForegroundColor Green }
