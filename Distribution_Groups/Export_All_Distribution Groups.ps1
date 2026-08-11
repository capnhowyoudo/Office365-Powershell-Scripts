<#
.SYNOPSIS
Exports all distribution groups in Exchange Online (or on-premises) to a CSV file.

.DESCRIPTION
This command retrieves all distribution groups using Get-DistributionGroup with no limit on the number of results.
It selects only the DisplayName, PrimarySmtpAddress, and GroupType properties and exports the data to a CSV file
located at C:\temp\Exchange_DLs.csv. The -NoTypeInformation parameter is used to prevent extra type info from 
being added to the CSV.

.NOTES
- Ensure the C:\temp\ folder exists or change the path accordingly.
- Requires the Exchange Online Management Module or Exchange Management Shell.
- This export can be used for reporting, auditing, or migration purposes.
#>

Get-DistributionGroup -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress, GroupType | Export-Csv -Path "C:\temp\Exchange_DLs.csv" -NoTypeInformation
