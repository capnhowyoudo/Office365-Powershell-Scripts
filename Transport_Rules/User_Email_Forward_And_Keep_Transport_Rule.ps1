<#
.SYNOPSIS
    Creates an Exchange Online transport rule that BCCs all mail sent to UserA to UserB.

.DESCRIPTION
    Connects to Exchange Online and creates a mail flow (transport) rule that matches any
    message sent to UserA (To, Cc, or Bcc) and blind-copies it to UserB. UserA still receives
    and keeps the original message, because the rule uses BCC rather than redirect.

    Messages sent from UserB are excluded to avoid duplicate copies or mail loops.
    The rule is created in Enforce mode and does not stop processing of other mail flow rules.
    After creation, the script displays the rule's key properties for verification and then
    disconnects from Exchange Online.

.NOTES
    Requirements:
      - ExchangeOnlineManagement module installed
      - Role permitted to manage transport rules (e.g., Exchange Administrator or
        Organization Management)

    Behavior:
      - The rule runs server-side; it does not appear in UserA's Outlook rules or settings.
      - Allow up to ~30 minutes for the rule to take effect.
      - Only mail sent TO UserA is copied. To also copy mail UserA sends, create a second
        rule using -From $userA.
      - If UserB is external, the outbound spam filter policy may interfere. Test with
        Message trace (Mail flow > Message trace in the Exchange admin center).
      - To test first, change -Mode Enforce to -Mode Audit or AuditAndNotify.

    Remove or disable:
      Disable-TransportRule -Identity "Copy mail for UserA to UserB"
      Remove-TransportRule  -Identity "Copy mail for UserA to UserB" -Confirm:$false

    Compliance:
      Make sure this is covered by organizational policy and applicable legal requirements
      (monitoring/notice/consent rules vary by jurisdiction).
#>

Connect-ExchangeOnline

$userA    = "usera@contoso.com"   # mailbox being copied
$userB    = "userb@contoso.com"   # where copies go
$ruleName = "Copy mail for UserA to UserB"

New-TransportRule -Name $ruleName `
    -SentTo $userA `
    -BlindCopyTo $userB `
    -ExceptIfFrom $userB `
    -Comments "BCC copy of all mail sent to $userA to $userB. Original stays in $userA's mailbox." `
    -Mode Enforce `
    -StopRuleProcessing $false

# Verify the rule
Get-TransportRule -Identity $ruleName | Format-List Name, State, Mode, SentTo, BlindCopyTo, ExceptIfFrom

Disconnect-ExchangeOnline -Confirm:$false
