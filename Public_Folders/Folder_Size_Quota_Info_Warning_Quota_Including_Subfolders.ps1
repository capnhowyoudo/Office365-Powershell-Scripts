<#
.SYNOPSIS
Retrieves quota and size information for a specified public folder and its subfolders.

.DESCRIPTION
This command queries the public folder at the given Identity path, including all
subfolders, and returns key properties such as Identity, ProhibitPostQuota,
IssueWarningQuota, and FolderSize. This is commonly used to audit storage and
quota settings within a public-folder structure.

.NOTES
Replace "\Info" with the appropriate public-folder path in your environment.
#>

Get-PublicFolder -Identity "\Info" -Recurse | Select-Object Identity, ProhibitPostQuota, IssueWarningQuota, FolderSize
