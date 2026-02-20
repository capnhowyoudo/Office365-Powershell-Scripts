<#
.SYNOPSIS
Generates a CSV report of email forwarding configurations in Exchange On-Premises.

.DESCRIPTION
This script audits and exports forwarding-related settings from an Exchange
On-Premises environment (Exchange Server 2013/2016/2019).

Depending on the parameter used, the script can report:

1. Mailbox-level forwarding
   - ForwardingSMTPAddress
   - ForwardingAddress
   - DeliverToMailboxAndForward

2. Inbox rules containing forwarding actions
   - ForwardTo
   - RedirectTo
   - ForwardAsAttachmentTo
   - Rule status and StopProcessingRules flag

3. Mail flow (transport) rules performing message redirection/forwarding
   - RedirectMessageTo
   - ForwardAsAttachmentTo
   - Rule state and mode

The results are appended to a timestamped CSV file created in the current
working directory.

.PARAMETER InboxRules
When specified, the script scans all user mailboxes for inbox rules that
forward, redirect, or forward messages as attachments.

.PARAMETER MailFlowRules
When specified, the script scans Exchange transport (mail flow) rules for
redirection/forwarding actions.

.EXAMPLE
.\ForwardingReport.ps1
Exports mailbox-level forwarding settings.

.EXAMPLE
.\ForwardingReport.ps1 -InboxRules
Exports inbox rules containing forwarding actions.

.EXAMPLE
.\ForwardingReport.ps1 -MailFlowRules
Exports transport/mail flow rules with redirect or forwarding actions.

.NOTES
Author: capnhowyoudo
Version:       1.0
Environment:   Exchange Server 2013 / 2016 / 2019 (On-Premises)
Requirements:
- Must be executed from Exchange Management Shell (EMS) or a session where
  Exchange cmdlets (e.g., Get-Mailbox, Get-InboxRule, Get-TransportRule)
  are available.
- Appropriate RBAC permissions to read mailbox and rule configurations.

Output:
- CSV file saved to the current directory
- File name includes report type and timestamp

Behavior:
- Uses -ResultSize Unlimited for full environment coverage
- Silently continues on inbox rule access errors
- Appends results to CSV if file already exists

Use Cases:
- Security audits
- Compliance checks
- Detection of unauthorized forwarding
- Incident response investigations
#>

<#
=============================================================================================
Name:          Export Exchange On-Prem Email Forwarding Report
Description:   Modified version for On-Premises (2013/2016/2019)
============================================================================================
#>

param(
    [Switch] $InboxRules,
    [Switch] $MailFlowRules
)

Function GetPrintableValue($RawData) {
    if (($null -eq $RawData) -or ($RawData -eq "")) {
        return "-";
    }
    else {
        # On-prem objects often need explicit string conversion for CSV export
        $StringVal = $RawData | Out-String
        return $StringVal.Trim();
    }
}

Function GetAllMailForwardingRules {
    Write-Host `n"Preparing the Email Forwarding Report..." -ForegroundColor Cyan
    
    if($InboxRules.IsPresent) {
        $global:ExportCSVFileName = "InboxRules_Forwarding_" + (Get-Date -format "yyyy-MM-dd_HH-mm").ToString() + ".csv"
        # Using -ResultSize Unlimited for On-Prem environments
        Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox | ForEach-Object { 
            Write-Progress -Activity "Checking Inbox Rules" -Status "Processing: $($_.DisplayName)"
            Get-InboxRule -Mailbox $_.DistinguishedName -ErrorAction SilentlyContinue | Where-Object { $_.ForwardAsAttachmentTo -ne $null -or $_.ForwardTo -ne $null -or $_.RedirectTo -ne $null} | ForEach-Object {
                $CurrUserRule = $_
                GetInboxRulesInfo
            }
        }
    }
    Elseif ($MailFlowRules.IsPresent) {
        $global:ExportCSVFileName = "TransportRules_Forwarding_" + (Get-Date -format "yyyy-MM-dd_HH-mm").ToString() + ".csv"
        Get-TransportRule | Where-Object { $_.RedirectMessageTo -ne $null -or $_.ForwardAsAttachmentTo -ne $null } | ForEach-Object {
            Write-Progress -Activity "Checking Transport Rules" -Status "Processing: $($_.Name)"
            $CurrEmailFlowRule = $_
            GetMailFlowRulesInfo
        }
    } 
    else{
        $global:ExportCSVFileName = "MailboxForwardingReport_" + (Get-Date -format "yyyy-MM-dd_HH-mm").ToString() + ".csv"
        Get-Mailbox -ResultSize Unlimited | Where-Object { $_.ForwardingSMTPAddress -ne $null -or $_.ForwardingAddress -ne $null} | ForEach-Object {
            Write-Progress -Activity "Checking Mailbox Forwarding" -Status "Processing: $($_.DisplayName)"
            $CurrEmailSetUp = $_
            GetMailboxForwardingInfo
        }
    }
}

Function GetMailboxForwardingInfo {
    $global:ReportSize++
    $MailboxOwner = $CurrEmailSetUp.PrimarySMTPAddress
    $DeliverToMailbox = $CurrEmailSetUp.DeliverToMailboxandForward 
    
    # On-prem logic for parsing address strings
    $ForwardingSMTPAddress = if ($CurrEmailSetUp.ForwardingSMTPAddress) { $CurrEmailSetUp.ForwardingSMTPAddress.ToString().Replace("smtp:","") } else { "-" }
    $ForwardTo = if ($CurrEmailSetUp.ForwardingAddress) { $CurrEmailSetUp.ForwardingAddress.ToString() } else { "-" }
    
    $ExportResult = New-Object PSObject -Property @{
        'Mailbox Name' = $MailboxOwner
        'Forwarding SMTP Address' = $ForwardingSMTPAddress
        'Forward To' = $ForwardTo
        'Deliver To Mailbox and Forward' = $DeliverToMailbox
    }
    $ExportResult | Select-Object 'Mailbox Name', 'Forwarding SMTP Address','Forward To','Deliver To Mailbox and Forward' | Export-CSV -Path $global:ExportCSVFileName -NoTypeInformation -Append
}

Function GetInboxRulesInfo {
    $global:ReportSize++
    $MailboxOwner = $CurrUserRule.MailboxOwnerId
    
    $ExportResult = New-Object PSObject -Property @{
        'Mailbox Name' = $MailboxOwner
        'Inbox Rule' = $CurrUserRule.Name
        'Rule Status' = $CurrUserRule.Enabled
        'Forward To' = ($CurrUserRule.ForwardTo -join "; ")
        'Redirect To' = ($CurrUserRule.RedirectTo -join "; ")
        'Forward As Attachment To' = ($CurrUserRule.ForwardAsAttachmentTo -join "; ")
        'Stop Processing Rules' = $CurrUserRule.StopProcessingRules
    }
    $ExportResult | Select-Object 'Mailbox Name', 'Inbox Rule', 'Forward To', 'Redirect To', 'Forward As Attachment To','Stop Processing Rules', 'Rule Status' | Export-CSV -Path $global:ExportCSVFileName -NoTypeInformation -Append
}

Function GetMailFlowRulesInfo {
    $global:ReportSize++
    
    $ExportResult = New-Object PSObject -Property @{
        'Mail Flow Rule Name' = $CurrEmailFlowRule.Name
        'State' = $CurrEmailFlowRule.State
        'Mode' = $CurrEmailFlowRule.Mode
        'Redirect To' = ($CurrEmailFlowRule.RedirectMessageTo -join "; ")
        'Stop Processing Rule' = $CurrEmailFlowRule.StopRuleProcessing
    }
    $ExportResult | Select-Object 'Mail Flow Rule Name','Redirect To', 'Stop Processing Rule','State', 'Mode' | Export-CSV -Path $global:ExportCSVFileName -NoTypeInformation -Append
}

# --- SCRIPT EXECUTION ---
$global:ReportSize = 0

# Check if Exchange Snap-in is loaded (standard for EMS)
if (!(Get-Command Get-Mailbox -ErrorAction SilentlyContinue)) {
    Write-Error "This script must be run from the Exchange Management Shell or a session with Exchange cmdlets loaded."
    return
}

GetAllMailForwardingRules
Write-Progress -Activity "Complete" -Completed

if (Test-Path $global:ExportCSVFileName) {     
    Write-Host `n"Report complete! File saved to: $(Get-Location)\$global:ExportCSVFileName" -ForegroundColor Green
    Write-Host "Total records found: $global:ReportSize"
} else {
    Write-Host "No forwarding configurations found." -ForegroundColor Yellow
}
