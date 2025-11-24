<#
.SYNOPSIS

Retrieves Azure AD license assignment changes from Unified Audit Logs for the past 90 days,
including add, remove, and change operations, with old/new SKU details.

.DESCRIPTION

This script connects to Exchange Online, queries Unified Audit Logs for license operations,
processes those records, and generates a CSV report and GridView output.

#>

# Connect to Exchange Online
Connect-ExchangeOnline

# Set date range for the audit logs
$StartDate = (Get-Date).AddDays(-90)
$EndDate = (Get-Date).AddDays(1)

Write-Host "Searching for license assignment audit records between $StartDate and $EndDate..." -ForegroundColor Cyan

try {
    # Broaden operation filters to include all relevant events
    [array]$Records = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -Formatted -ResultSize 5000 `
        -Operations "Change user license","Update user","Add license to user","Remove license from user" -SessionCommand ReturnLargeSet
} catch {
    Write-Host "Error retrieving audit records: $_" -ForegroundColor Red
    exit
}

if (!($Records)) {
    Write-Host "No audit records found... exiting..." -ForegroundColor Yellow
    exit
}

Write-Host ("Processing {0} records..." -f $Records.count) -ForegroundColor Cyan

# Sort by creation date (newest first)
$Records = $Records | Sort-Object {[datetime]$_.CreationDate} -Descending

# Separate by type
[array]$LicenseEvents = $Records | Where-Object {$_.Operations -match "license"}
[array]$UserUpdates = $Records | Where-Object {$_.Operations -eq "Update user"}

# Initialize report collection
$Report = [System.Collections.Generic.List[Object]]::new()

foreach ($Event in $LicenseEvents) {
    try {
        $AuditData = $Event.AuditData | ConvertFrom-Json
        $CreationDate = [datetime]$Event.CreationDate

        # Find nearby user update record within ±2 minutes
        [array]$Detail = $UserUpdates | Where-Object {
            ($_.UserIds -eq $Event.UserIds) -and
            ([datetime]$_.CreationDate -ge $CreationDate.AddMinutes(-2)) -and
            ([datetime]$_.CreationDate -le $CreationDate.AddMinutes(2))
        }

        $OldSkuNames = $NewSkuNames = $null

        if ($Detail) {
            $LicenseData = $Detail[0].AuditData | ConvertFrom-Json
            $ModifiedProps = $LicenseData.ModifiedProperties | Where-Object {$_.Name -eq 'AssignedLicense'}

            if ($ModifiedProps) {
                # Parse old values
                if ($ModifiedProps.OldValue) {
                    try {
                        $OldLicenses = $ModifiedProps.OldValue | ConvertFrom-Json
                        $OldSkuNames = ($OldLicenses | ForEach-Object {
                            ($_ -split '[,=]')[1]
                        }) -join ", "
                    } catch {}
                }

                # Parse new values
                if ($ModifiedProps.NewValue) {
                    try {
                        $NewLicenses = $ModifiedProps.NewValue | ConvertFrom-Json
                        $NewSkuNames = ($NewLicenses | ForEach-Object {
                            ($_ -split '[,=]')[1]
                        }) -join ", "
                    } catch {}
                }
            }
        }

        # Add line to report
        $Report.Add([PSCustomObject]@{
            'Operation'     = $AuditData.Operation
            'Timestamp'     = (Get-Date($AuditData.CreationTime) -format "yyyy-MM-dd HH:mm:ss")
            'Performed By'  = $AuditData.UserId
            'Target User'   = $AuditData.ObjectId
            'Old SKU(s)'    = $OldSkuNames
            'New SKU(s)'    = $NewSkuNames
        })
    } catch {
        Write-Host "Error processing record for $($Event.UserIds): $_" -ForegroundColor Red
    }
}

# Sort report and export
$Report = $Report | Sort-Object {[datetime]$_.Timestamp}
$ExportPath = "C:\temp\LicenseAssignmentReport.csv"

if (!(Test-Path "C:\temp")) { New-Item -ItemType Directory -Path "C:\temp" | Out-Null }
$Report | Export-Csv $ExportPath -NoTypeInformation -Encoding UTF8
$Report | Out-GridView

Write-Host "`nReport exported to $ExportPath" -ForegroundColor Green
