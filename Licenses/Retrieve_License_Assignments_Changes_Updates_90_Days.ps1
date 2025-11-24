<#
.SYNOPSIS

Retrieves Azure AD license assignment changes from Unified Audit Logs for the past 90 days,
including add, remove, and change operations, with old/new SKU details.

.DESCRIPTION

This script connects to Exchange Online, queries Unified Audit Logs for license operations,
processes those records, and generates a CSV report and GridView output.

#>

Connect-ExchangeOnline
# Azure AD license assignment script
$StartDate = (Get-Date).AddDays(-90)
$EndDate = (Get-Date).AddDays(1)
Write-Host "Searching for license assignment audit records"
[array]$Records = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -Formatted -ResultSize 5000 -Operations "Change user license", "Update User" -SessionCommand ReturnLargeSet
If (!($Records)) { Write-Host "No audit records found... exiting... " ; break}

Write-Host ("Processing {0} records" -f $Records.count)
$Records = $Records | Sort-Object {$_.CreationDate -as [datetime]} -Descending
[array]$LicenseUpdates = $Records | Where-Object {$_.Operations -eq "Change user license."}
[array]$UserUpdates = $Records | Where-Object {$_.Operations -eq "Update user."}

$Report = [System.Collections.Generic.List[Object]]::new()

ForEach ($L in $LicenseUpdates) {
  $NewLicenses = $Null; $OldLicenses = $Null; $OldSkuNames = $Null; $NewSkuNames = $Null
  $AuditData = $L.AuditData | ConvertFrom-Json
  $CreationDate = Get-Date($L.CreationDate) -format s
  [array]$Detail = $UserUpdates | Where-Object {$_.CreationDate -eq $CreationDate -and $_.UserIds -eq $L.UserIds}
  If ($Detail) { # Found a user update record
     [int]$i = 0
     $LicenseData = $Detail[0].AuditData | ConvertFrom-Json
     [array]$OldLicenses = $LicenseData.ModifiedProperties | Where {$_.Name -eq 'AssignedLicense'} | Select-Object -ExpandProperty OldValue | Convertfrom-Json
     If ($OldLicenses) {
        [array]$OldSkuNames = $Null
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

  } # end if
  $ReportLine   = [PSCustomObject] @{ 
     Operation      = $AuditData.Operation
     Timestamp      = Get-Date($AuditData.CreationTime) -format g
     'Assigned by'  = $AuditData.UserId
     'Assigned to'  = $AuditData.ObjectId 
     'Old SKU'      = $OldSkuNames
     'New SKU'      = $NewSkuNames
     'New licenses' = $NewLicenses
     'Old licenses' = $OldLicenses
  }
  $Report.Add($ReportLine)
}

$Report = $Report | Sort-Object {$_.TimeStamp -as [datetime]} 
$Report | Out-GridView

