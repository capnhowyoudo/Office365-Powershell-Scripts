# Export Office 365 Mailbox Hold Report

When organizations face legal or compliance requirements, they must preserve mailbox data (emails, calendars, and notes) to ensure it isn't deleted. Because a single mailbox can be subject to multiple holds, identifying and managing these holds is a critical—yet often difficult—task for IT administrators.
Why Identify Mailbox Hold Types?

Administrators must track Litigation, In-Place, and Retention holds to optimize the environment. Key reasons include:

- Cost Reduction: Identify and remove holds on inactive mailboxes to save on licensing.
- Storage Management: Adjust hold durations for high-storage mailboxes to free up space.
- Legal Compliance: Ensure critical data is preserved for the required duration.
- Strategic Optimization: Consolidate multiple holds into the most efficient hold technique.
- Lifecycle Management: Use start and end dates to manage time-based holds effectively.

# Limitations of Standard Discovery Methods

Authorized admins (Global, Exchange, or Compliance) can view hold statuses, but current tools have significant gaps:

- Exchange Admin Center (EAC): While you can add a "Litigation Hold" column to the mailbox view, there is no aggregated report for all hold types. Furthermore, In-Place and Retention hold details are either obsolete or invisible within the EAC UI.
- PowerShell: Standard commands like Get-Mailbox often return cryptic GUIDs rather than clear hold names, making it difficult to differentiate between specific hold types without complex filtering.

# Solution: The All-in-One Mailbox Hold Report Script

To bypass these limitations, we developed MailboxHoldReport.ps1. This script automates the analysis of your environment and provides a clear, comprehensive overview of all hold activities.
Key Features:

- Comprehensive Reporting: Generates four distinct reports covering Litigation, In-Place, and Retention holds.
- Detailed Analytics: Lists every mailbox with its active hold info, duration, and associated policies.
- Ease of Use: Automatically installs the required Exchange Online modules and supports both MFA and non-MFA accounts.
- Automation Ready: Export results directly to CSV or schedule the script to run automatically by passing credentials as parameters.

Download and save the script as MailboxHoldReport.ps1

    <#
    =============================================================================================
    Name:           Export Office 365 Mailbox Holds Report
    Description:    This script exports hold enabled mailboxes to CSV
    Version:        1.0
    Website:        o365reports.com

    Script Highlights: 
    ~~~~~~~~~~~~~~~~~
    1.Generates 4 different mailbox holds reports.  
    2.Automatically installs the Exchange Online module upon your confirmation when it is not available in your machine. 
    3.Shows list of the mailboxes with all the active holds information for each mailbox. 
    4.Shows the mailboxes with litigation hold enabled along with hold duration and other details. 
    5.Displays in-place hold applied mailboxes. 
    6.Lists mailboxes that are placed on retention hold and their retention policy. 
    7.Supports both MFA and Non-MFA accounts.    
    8.Exports the report in CSV format.  
    9.Scheduler-friendly. You can automate the report generation upon passing credentials as parameters. 
    
    For detailed Script execution: http://o365reports.com/2021/06/29/export-office-365-mailbox-holds-report-using-powershell
    ============================================================================================
    #>
    
    param (
        [string] $UserName = $null,
        [string] $Password = $null,
        [Switch] $LitigationHoldsOnly,
        [Switch] $InPlaceHoldsOnly,
        [Switch] $RetentionHoldsOnly
    )
    
    Function GetBasicData {
        $global:ExportedMailbox = $global:ExportedMailbox + 1
        $global:MailboxName = $_.Name 
        $global:RecipientTypeDetails = $_.RecipientTypeDetails
        $global:UPN = $_.UserPrincipalName
    }
    Function RetrieveAllHolds {
        if ($LitigationHoldsOnly.IsPresent) {
            $global:ExportCSVFileName = "LitigationHoldsReport" + ((Get-Date -format "MMM-dd hh-mm-ss tt").ToString()) + ".csv"
                Get-mailbox -IncludeInactiveMailbox -ResultSize Unlimited | Where-Object { $_.LitigationHoldEnabled -eq $True } | foreach-object {
                $CurrLitigationHold = $_
                GetLitigationHoldsReport
            }
        }
        elseif ($InPlaceHoldsOnly.IsPresent) {
            $global:ExportCSVFileName = "InPlaceHoldsReport" + ((Get-Date -format "MMM-dd hh-mm-ss tt").ToString()) + ".csv"
            Get-mailbox -IncludeInactiveMailbox -ResultSize Unlimited | Where-Object { $_.InPlaceHolds -ne $Empty } | foreach-object {
                $CurrInPlaceHold = $_
                GetInPlaceHoldsReport
            }
        }
        elseif ($RetentionHoldsOnly.IsPresent) {
            $global:ExportCSVFileName = "RetentionHoldsReport" + ((Get-Date -format "MMM-dd hh-mm-ss tt").ToString()) + ".csv"
            Get-mailbox -IncludeInactiveMailbox -ResultSize Unlimited | Where-Object { $_.RetentionHoldEnabled -eq $True } | foreach-object {
                $CurrRetentionHold = $_
                GetRetentionHoldsReport
            }
        }
        else {
            $global:ExportCSVFileName = "AllActiveHoldsReport" + ((Get-Date -format "MMM-dd hh-mm-ss tt").ToString()) + ".csv"
            Get-mailbox -IncludeInactiveMailbox -ResultSize Unlimited | Where-Object { $_.LitigationHoldEnabled -eq $True -or $_.RetentionHoldEnabled -eq $True -or $_.InPlaceHolds -ne $Empty -or $_.ComplianceTagHoldApplied -eq $True } | foreach-object {
                $CurrMailbox = $_
                GetDefaultReport
            }
        }
    }
    
    Function GetInPlaceHoldType($HoldGuidList) {
        $HoldTypes = @()
        $InPlaceHoldCount = 0
        $HoldGuidList | ForEach-Object {
            $InPlaceHoldCount = $InPlaceHoldCount + 1
            if ($_ -match "UniH") {
                $HoldTypes += "eDiscovery Case"
            }
            elseif ($_ -match "^mbx") {
                $HoldTypes += "Specific Location Retention Policy"
            }
            elseif ($_ -match "^\-mbx") {
                $HoldTypes += "Mailbox Excluded Retention Policy"
            }
            elseif ($_ -match "skp") {
                $HoldTypes += "Retention Policy on Skype"
            }
            else {
                $HoldTypes += "In-Place Hold"
            }
        }
        
        return ($HoldTypes -join ", "), $InPlaceHoldCount
    }
    
    Function GetLitigationHoldsReport {
        GetBasicData
        $LitigationOwner = $CurrLitigationHold.LitigationHoldOwner
        if ($null -ne $CurrLitigationHold.LitigationHoldDate) {
            $LitigationHoldDate = ($CurrLitigationHold.LitigationHoldDate).ToString().Split(" ") | Select-Object -Index 0
        }
        $LitigationDuration = $CurrLitigationHold.LitigationHoldDuration
        if ($LitigationDuration -ne "Unlimited") {
            $LitigationDuration = ($LitigationDuration).split(".") | Select-Object -Index 0
        }
    
        Write-Progress "Retrieving the Litigation Hold Information for the User: $global:MailboxName" "Processed Mailboxes Count: $global:ExportedMailbox" 
    
        #ExportResult
        $ExportResult = @{'Mailbox Name' = $global:MailboxName; 'Mailbox Type' = $global:RecipientTypeDetails; 'UPN' = $global:UPN; 'Litigation Owner' = $LitigationOwner; 'Litigation Duration' = $LitigationDuration; 'Litigation Hold Date' = $LitigationHoldDate }
        $ExportResults = New-Object PSObject -Property $ExportResult
        $ExportResults | Select-object 'Mailbox Name', 'UPN', 'Mailbox Type',  'Litigation Owner', 'Litigation Duration', 'Litigation Hold Date' | Export-csv -path $global:ExportCSVFileName -NoType -Append -Force  
    }
    
    Function GetInPlaceHoldsReport {
        GetBasicData
        $InPlaceHoldInfo = GetInPlaceHoldType ($CurrInPlaceHold.InPlaceHolds)
        $InPlaceHoldType = $InPlaceHoldInfo[0]
        $NumberOfHolds = $InPlaceHoldInfo[1]
    
        Write-Progress "Retrieving the In-Place Hold Information for the User: $global:MailboxName" "Processed Mailboxes Count: $global:ExportedMailbox"
    
        #Export Results
        $ExportResult = @{'Mailbox Name' = $global:MailboxName; 'Mailbox Type' = $global:RecipientTypeDetails; 'UPN' = $global:UPN; 'Configured InPlace Hold Count' = $NumberOfHolds; 'InPlace Hold Type' = $InPlaceHoldType }
        $ExportResults = New-Object PSObject -Property $ExportResult
        $ExportResults | Select-object 'Mailbox Name', 'UPN', 'Mailbox Type',  'Configured InPlace Hold Count', 'InPlace Hold Type' | Export-csv -path $global:ExportCSVFileName -NoType -Append -Force 
    }
    
    Function GetRetentionHoldsReport {
        GetBasicData
        $RetentionPolicy = $CurrRetentionHold.RetentionPolicy
        $RetentionPolicyTag = ((Get-RetentionPolicy -Identity $RetentionPolicy).RetentionPolicyTagLinks) -join ","
    
        if (($CurrRetentionHold.StartDateForRetentionHold) -ne $Empy) {
            $StartDateForRetentionHold = ($CurrRetentionHold.StartDateForRetentionHold).ToString().split(" ") | Select-Object -Index 0
        }
        else {
            $StartDateForRetentionHold = "-"
        }
        if (($CurrRetentionHold.EndDateForRetentionHold) -ne $Empy) {
            $EndDateForRetentionHold = ($CurrRetentionHold.EndDateForRetentionHold).ToString().split(" ") | Select-Object -Index 0
        }
        else {
            $EndDateForRetentionHold = "-"   
        }
    
        Write-Progress "Retrieving the Retention Hold Information for the User: $global:MailboxName" "Processed Mailboxes Count: $global:ExportedMailbox"
    
        #ExportResult
        $ExportResult = @{'Mailbox Name' = $global:MailboxName; 'Mailbox Type' = $global:RecipientTypeDetails; 'UPN' = $global:UPN; 'Retention Policy Name' = $RetentionPolicy; 'Start Date for Retention Hold' = $StartDateForRetentionHold; 'End Date for Retention Hold' = $EndDateForRetentionHold; 'Retention Policy Tag' = $RetentionPolicyTag }
        $ExportResults = New-Object PSObject -Property $ExportResult
        $ExportResults | Select-object 'Mailbox Name', 'UPN', 'Mailbox Type',  'Retention Policy Name', 'Start Date for Retention Hold', 'End Date for Retention Hold', 'Retention Policy Tag' | Export-csv -path $global:ExportCSVFileName -NoType -Append -Force 
    }
    
    Function GetDefaultReport {
        GetBasicData
        $LitigationHold = $CurrMailbox.LitigationHoldEnabled
        $ComplianceTag = $CurrMailbox.ComplianceTagHoldApplied
        $RetentionHold = $CurrMailbox.RetentionHoldEnabled
        $ArchiveStatus = $CurrMailbox.ArchiveStatus
        $RetentionPolicy = $CurrMailbox.RetentionPolicy
        
        $LitigationDuration = $CurrMailbox.LitigationHoldDuration
        if ($LitigationDuration -ne "Unlimited") {
            $LitigationDuration = ($LitigationDuration).split(".") | Select-Object -Index 0
        }
        $InPlaceHold = $CurrMailbox.InPlaceHolds
        if ($InPlaceHold -ne $Empty) {
            $InPlaceHold = "Enabled"
        }
        else {
            $InPlaceHold = "Disabled"
        }
    
        Write-Progress "Retrieving All Active Holds Applied on the User: $global:MailboxName" "Processed Mailboxes Count: $global:ExportedMailbox"
                
        #ExportResult
        $ExportResult = @{'Mailbox Name' = $global:MailboxName; 'Mailbox Type' = $global:RecipientTypeDetails; 'UPN' = $global:UPN; 'Archive Status' = $ArchiveStatus; 'Litigation Hold Enabled' = $LitigationHold; 'Compliance Tag Hold Enabled' = $ComplianceTag; 'Retention Hold Enabled' = $RetentionHold; 'Litigation Duration' = $LitigationDuration; 'In-Place Hold Status' = $InPlaceHold; 'Retention Policy Name' = $RetentionPolicy }
        $ExportResults = New-Object PSObject -Property $ExportResult
        $ExportResults | Select-object 'Mailbox Name', 'UPN', 'Mailbox Type',  'Archive Status', 'Litigation Hold Enabled', 'In-Place Hold Status', 'Retention Hold Enabled', 'Compliance Tag Hold Enabled', 'Litigation Duration', 'Retention Policy Name' | Export-csv -path $global:ExportCSVFileName -NoType -Append -Force 
    
    }
    Function ConnectToExchange {
        $Exchange = (get-module ExchangeOnlineManagement -ListAvailable).Name
        if ($Exchange -eq $null) {
            Write-host "Important: ExchangeOnline PowerShell module is unavailable. It is mandatory to have this module installed in the system to run the script successfully." 
            $confirm = Read-Host Are you sure you want to install module? [Y] Yes [N] No  
            if ($confirm -match "[yY]") { 
                Write-host "Installing ExchangeOnlineManagement"
                Install-Module ExchangeOnlineManagement -Repository PSGallery -AllowClobber -Force
                Write-host "ExchangeOnline PowerShell module is installed in the machine successfully."
            }
            elseif ($confirm -cnotmatch "[yY]" ) { 
                Write-host "Exiting. `nNote: ExchangeOnline PowerShell module must be available in your system to run the script." 
                Exit 
            }
        }
        #Storing credential in script for scheduling purpose/Passing credential as parameter
        if (($UserName -ne "") -and ($Password -ne "")) {   
            $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force   
            $Credential = New-Object System.Management.Automation.PSCredential $UserName, $SecuredPassword 
            Connect-ExchangeOnline -Credential $Credential -ShowProgress $false | Out-Null
        }
        else {
            Connect-ExchangeOnline | Out-Null
        }
        Write-Host "ExchangeOnline PowerShell module is connected successfully"
        #End of Connecting Exchange Online
    }
    
    ConnectToExchange
    $global:ExportedMailbox = 0
    RetrieveAllHolds
      
    if ((Test-Path -Path $global:ExportCSVFileName) -eq "True") {     
        Write-Host `n" The output file available in:"  -NoNewline -ForegroundColor Yellow 
    	Write-Host .\$global:ExportCSVFileName 
    	Write-Host ""
        Write-host "There are $global:ExportedMailbox mailboxes records in the output file" `n
        $prompt = New-Object -ComObject wscript.shell    
        $userInput = $prompt.popup("Do you want to open output file?", 0, "Open Output File", 4)    
        If ($userInput -eq 6) {    
            Invoke-Item "$global:ExportCSVFileName"
        }  
    }
    else {
        Write-Host "No data found with the specified criteria"
    }
    Disconnect-ExchangeOnline -Confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue
    Write-Host "Disconnected active ExchangeOnline session"
    Write-Host `n~~ Script prepared by AdminDroid Community ~~`n -ForegroundColor Green
    Write-Host "~~ Check out " -NoNewline -ForegroundColor Green; Write-Host "admindroid.com" -ForegroundColor Yellow -NoNewline; Write-Host " to get access to 1800+ Microsoft 365 reports. ~~" -ForegroundColor Green `n`n

# Mailbox Hold Report – Script Execution Overview

The generated report allows administrators to instantly identify every mailbox under a hold within the organization. By providing granular attributes for each entry, the report makes it easy to audit existing policies or reconstruct hold settings when necessary.

With a streamlined execution process, you can generate the following four targeted reports:

- Mailboxes Under Hold(s): A comprehensive overview of all mailboxes currently restricted.
- Litigation Holds Report: A specific breakdown of mailboxes with litigation holds enabled.
- In-Place Holds Report: Detailed visibility into mailboxes affected by In-Place holds.
- Retention Holds Report: A clear list of mailboxes subject to retention policies.

Follow the steps outlined below to provide your inputs and generate these reports.

# List All Office 365 Mailbox in Holds:

To satisfy legal, investigative, and compliance mandates, a single mailbox may be subject to multiple overlapping holds. Managing these can be challenging for administrators, as it is often difficult to track which holds apply to which mailbox and to identify the unique properties of each hold type.

The Active Holds Report simplifies this process by providing a centralized view, allowing you to quickly access comprehensive hold information for every mailbox in your environment.

    .\MailboxHoldReport.ps1

In addition to standard hold details, the script’s simplified execution provides visibility into archive mailbox statuses and the ComplianceTagHoldApplied state, ensuring a complete view of your data preservation settings.

:information_source: Sample Output

<img width="1588" height="154" alt="image" src="https://github.com/user-attachments/assets/b12792a7-1237-4051-81d3-52089475cd0b" />

# Litigation Hold Report in Office 365:

Administrators are tasked with managing mailbox storage, recovering deleted items, and ensuring that user-deleted content is preserved for compliance. Our script provides full visibility into litigation hold statuses and all associated details. By using this report, you can analyze specific hold properties and refine your litigation hold policies to better align with your organization’s current requirements.

    .\MailboxHoldReport.ps1 -LitigationHoldsOnly

To isolate mailboxes specifically under litigation hold, use the -LitigationHoldsOnly switch parameter. The resulting report includes detailed, litigation-specific attributes such as:

- LitigationHoldOwner: The account that placed the hold.
- LitigationHoldDuration: The specific timeframe the data is preserved.
- LitigationHoldDate: Exactly when the hold was initially applied.

:information_source: Sample Output

<img width="865" height="113" alt="image" src="https://github.com/user-attachments/assets/a8705ba3-6668-4431-a66d-78c5e3a94413" />

# List In-Place Hold Enabled Mailboxes:

When a mailbox is involved in multiple legal investigations, administrators often apply several In-Place holds simultaneously. Our In-Place Hold Report helps admins identify which mailboxes currently lack protection so they can enable holds where necessary.

Furthermore, the report allows administrators to verify that email content remains truly immutable—protected from both manual user deletion and automated system processes like Messaging Records Management (MRM).

    .\MailboxHoldReport.ps1 -InPlaceHoldsOnly

To filter the results specifically for mailboxes with In-Place holds, use the -InPlaceHoldsOnly switch parameter. If a mailbox is subject to multiple holds, the report will provide an accurate count and specify the hold types—such as In-Place, eDiscovery Case, or Specific location Retention Policy—as illustrated in the reference image.

:information_source: Sample Output 

<img width="815" height="138" alt="image" src="https://github.com/user-attachments/assets/a332f352-2879-4c48-9f81-29b82770aedb" />

# Get Office 365 Mailbox with Retention Holds Report:

Retention holds can be configured to preserve content across Exchange Online, Microsoft 365 Groups, and Microsoft Teams. By enabling a retention hold, administrators can temporarily suspend the Managed Folder Assistant’s MRM (Messaging Records Management) processes for specific mailboxes.

The Retention Hold Report identifies these mailboxes and provides essential details, including the specific retention policy in effect and the scheduled end date for each hold.

    .\MailboxHoldReport.ps1 -RetentionHoldsOnly

To isolate mailboxes with an active retention hold, use the -RetentionHoldsOnly switch parameter. The resulting report provides a clear overview of the hold's parameters: the Retention Policy Tag offers a concise description of the policy, while the Start Date and End Date fields precisely define the hold's duration.

:information_source: Sample Output 

<img width="1256" height="104" alt="image" src="https://github.com/user-attachments/assets/7b10b4f1-c6e8-4b29-8db0-d782257faceb" />

# Scheduling Office 365 Mailbox on Hold Report:

Because many mailbox holds are permanent, scheduling this PowerShell script is an effective way to continuously monitor hold statuses. The script supports both MFA and non-MFA accounts for automated execution.

To schedule the report using a non-MFA administrative account, use the following format:

    .\MailboxHoldReport.ps1 -UserName admin@contoso.com -Password (password) -LitigationHoldsOnly

Admin accounts with MFA enabled cannot be used directly for automated scheduling. To facilitate scheduled execution, you must bypass MFA for that specific account by configuring an exception within your Conditional Access Policies.




