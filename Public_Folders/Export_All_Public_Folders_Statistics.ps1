<#
.SYNOPSIS
Exports public folder statistics to a CSV file.

.DESCRIPTION
This command retrieves statistics for all public folders, selects key properties
including Name, FolderPath, ItemCount, TotalItemSize, and TotalDeletedItemSize,
and exports the results to a CSV file for reporting or analysis.

.NOTES
Update the export path if your environment uses a different directory.
#>

Get-PublicFolderStatistics | Select-Object Name, FolderPath, ItemCount, TotalItemSize, TotalDeletedItemSize | Export-Csv "C:\Temp\PFStatistics.csv" -NoTypeInformation
