<#
.SYNOPSIS
Retrieves the members of a specified unified group and exports their details to a CSV file.

.DESCRIPTION
This cmdlet retrieves a list of all members from a unified group, along with their display name, primary SMTP address, recipient type, and the date when they were created. The information is then exported to a CSV file for further analysis.

.PARAMETER Identity
Specifies the identity of the unified group whose members are being retrieved. The identity can be the group's name or email address.

.NOTES
Example Usage:
    Get-UnifiedGroup -Identity "GroupName" | Get-UnifiedGroupLinks -LinkType Member | Select Displayname, PrimarySmtpAddress, RecipientType, WhenCreated | Export-Csv -Path C:\Path\To\Export\File.csv
    This will export the list of members in the "GroupName" unified group to `C:\Path\To\Export\File.csv`.
    
This script is useful for extracting and analyzing the members of a unified group in Exchange Online, and for exporting their information into a CSV format.

#>

# Retrieve members of the unified group "GroupName" and export relevant details to a CSV file, then display confirmation

Get-UnifiedGroup -Identity "GroupName" | Get-UnifiedGroupLinks -LinkType Member | Select Displayname, PrimarySmtpAddress, RecipientType, WhenCreated | Export-Csv -Path C:\Path\To\Export\File.csv -NoTypeInformation; Write-Host "The group members have been exported to C:\Path\To\Export\File.csv"
