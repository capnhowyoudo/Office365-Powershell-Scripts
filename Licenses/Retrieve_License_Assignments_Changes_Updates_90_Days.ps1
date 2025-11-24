<#
.SYNOPSIS
This script retrieves and processes Azure AD license assignment changes and updates from Unified Audit Logs for the past 90 days. It generates a report detailing the changes in user licenses, including old and new SKUs.

.DESCRIPTION
This PowerShell script connects to Exchange Online, queries Unified Audit Logs for license assignment and user update operations within a 90-day window, and processes those records to generate a detailed report. The script looks for "Change user license" and "Update user" operations, extracting and comparing old and new license data (SKUs) for each user. The report contains details such as the user ID, operation timestamp, old and new licenses assigned, and the user who performed the change.

.NOTES
This script is useful for administrators who need to audit and track license assignment changes in Azure AD. It extracts detailed audit log information for license changes, including SKU names, and outputs the result in both a grid view and CSV format for further analysis.

Example Usage:
    Run the script to retrieve the license assignment audit records for the past 90 days and generate a CSV report.

#>

# Connect to Exchange Online
Connect-ExchangeOnline

# Set date range for the audit logs
$StartDate = (Get-Date).AddDays(-90)
$EndDate = (Get-Date).AddDays(1)

Write-Host "Searching for license assignment audit records..."

try {
    # Search the Unified Audit Log
    [array]$Records = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -Formatted -ResultSize 5000 -Operations "Change user license", "Update User" -SessionCommand ReturnLargeSet
} catch {
    Write-Host "Error retrieving audit records: $_"
    exit
}

If (!($Records)) {
    Write-Host "No audit records found... exiting..."
    exit
}

Write-Host ("Processing {0} records" -f $Records.count)

# Sort records by creation date (newest first)
$Records = $Records | Sort-Object {$_.CreationDate -as [datetime]} -Descending

# Filter out license updates and user updates
[array]$LicenseUpdates = $Records | Where-Object {$_.Operations -eq "Change user license"}
[array]$UserUpdates = $Records | Where-Object {$_.Operations -eq "Update user"}

# Initialize report collection
$Report = [System.Collections.Generic.List[Object]]::new()

ForEach ($L in $LicenseUpdates) {
    $NewLicenses = $Null; $OldLicenses = $Null; $OldSkuNames = $Null; $NewSkuNames = $Null
    $AuditData = $L.AuditData | ConvertFrom-Json
    $CreationDate = Get-Date($L.CreationDate) -format "yyyy-MM-dd HH:mm:ss"
    
    # Find corresponding user update record
    [array]$Detail = $UserUpdates | Where-Object {$_.CreationDate -eq $CreationDate -and $_.UserIds -eq $L.UserIds}
    
    If ($Detail) { 
        $LicenseData = $Detail[0].AuditData | ConvertFrom-Json
        [array]$OldLicenses = $LicenseData.ModifiedProperties | Where {$_.Name -eq 'AssignedLicense'} | Select-Object -ExpandProperty OldValue | Convertfrom-Json
        If ($OldLicenses) {
            [array]$OldSkuNames = $Null
            $i = 0
            ForEach ($OSku in $OldLicenses) {
                $OldSkuName = $OldLicenses[$i].Substring(($OldLicenses[$i].IndexOf("=")+1), ($OldLicenses[$i].IndexOf(",")-$OldLicenses[$i].IndexOf("="))-1)
                $OldSkuNames += $OldSkuName
                $i++
            }
            $OldSkuNames = $OldSkuNames -join ", "
        }

        [array]$NewLicenses = $LicenseData.ModifiedProperties | Where {$_.Name -eq 'AssignedLicense'} | Select-Object -ExpandProperty NewValue | Convertfrom-Json
        If ($NewLicenses) {
            $i = 0
            [array]$NewSkuNames = $Null
            ForEach ($N in $NewLicenses) {
                $NewSkuName = $NewLicenses[$i].Substring(($NewLicenses[$i].IndexOf("=")+1), ($NewLicenses[$i].IndexOf(",")-$NewLicenses[$i].IndexOf("="))-1)
                $NewSkuNames += $NewSkuName
                $i++
            }
            $NewSkuNames = $NewSkuNames -join ", "
        }
    }

    # Prepare report line
    $ReportLine = [PSCustomObject] @{
        Operation      = $AuditData.Operation
        Timestamp      = Get-Date($AuditData.CreationTime) -format "yyyy-MM-dd HH:mm:ss"
        'Assigned by'  = $AuditData.UserId
        'Assigned to'  = $AuditData.ObjectId
        'Old SKU'      = $OldSkuNames
        'New SKU'      = $NewSkuNames
        'New licenses' = $NewLicenses
        'Old licenses' = $OldLicenses
    }
    $Report.Add($ReportLine)
}

# Sort by timestamp and export to CSV
$Report = $Report | Sort-Object {$_.Timestamp -as [datetime]}
$ExportPath = "C:\temp\LicenseAssignmentReport.csv"
$Report | Export-Csv $ExportPath -NoTypeInformation

# Display the report in grid view
$Report | Out-GridView

Write-Host "Report has been exported to $ExportPath"
