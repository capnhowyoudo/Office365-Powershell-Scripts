<#
.SYNOPSIS
Preview recipients of a dynamic distribution group and export to CSV.

.DESCRIPTION
This script retrieves the recipient preview for a Dynamic Distribution Group (DDG) in Exchange Online or Exchange On-Premises.
It first gets the DDG object and then evaluates the RecipientPreviewFilter to show which mailboxes/users currently match the dynamic criteria.
The output is displayed in the console and exported to a CSV file for reporting purposes.

.NOTES
- Replace "DynamicGroup1" with the actual Dynamic Distribution Group name.
- The RecipientPreviewFilter allows you to see which recipients would receive emails sent to this dynamic group.
- Output CSV is saved to C:\Temp\DynamicGroupPreview.csv.
- Useful for verification before sending emails to large dynamic groups.
#>

# Ensure export folder exists
$ExportFolder = "C:\Temp"
if (-not (Test-Path $ExportFolder)) { New-Item -ItemType Directory -Path $ExportFolder }

# Variables
$DynamicDDG = Get-DynamicDistributionGroup -Identity "DynamicGroup1"
$ExportPath = Join-Path $ExportFolder "DynamicGroupPreview.csv"

# Preview recipients matching the dynamic filter
$Recipients = Get-Recipient -RecipientPreviewFilter ($DynamicDDG.RecipientFilter) | 
    Select-Object Name, PrimarySmtpAddress, RecipientType

# Display in console
$Recipients | Format-Table -AutoSize

# Export to CSV
$Recipients | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8

Write-Host "`nRecipient preview exported to $ExportPath" -ForegroundColor Green
