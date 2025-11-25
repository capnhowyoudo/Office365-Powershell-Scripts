<#
.SYNOPSIS
Connects to Microsoft Graph and exports Microsoft 365 subscribed SKU information to CSV.

.DESCRIPTION
First, establishes a connection to Microsoft Graph with the required scopes for reading 
and writing users and groups. Then, retrieves all subscribed SKU details and exports 
the complete dataset to a CSV file.

.NOTES
Requires Microsoft Graph PowerShell module (Mg).  
Ensure you have permission to use the specified scopes.  
All properties from Get-MgSubscribedSku are exported without filtering.  
Adjust the CSV path as needed.
#>

Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All"
Get-MgSubscribedSku | Export-Csv -Path "C:\Temp\SubscribedSku.csv" -NoTypeInformation
