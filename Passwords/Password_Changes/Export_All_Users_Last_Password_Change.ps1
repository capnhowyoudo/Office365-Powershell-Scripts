<#
.SYNOPSIS
Export Microsoft 365 users' last password change timestamp to a CSV file.

.DESCRIPTION
This script connects to Microsoft Graph, retrieves selected properties of all Microsoft 365 users, 
including their last password change timestamp, and exports the data to a CSV file. 
The exported CSV can be used for auditing, reporting, or tracking password change compliance.

.PARAMETER Properties
Properties to retrieve for each user. By default, includes: id, DisplayName, UserPrincipalName, 
PasswordPolicies, lastPasswordChangeDateTime, mail, jobtitle, department.

.OUTPUTS
CSV file containing the requested user properties.

.EXAMPLE
# Export all users' last password change info to a CSV
.\Export_All_Users_Last_Password_Change.ps1

.NOTES
Written by: ALI TAJRAN
Website:    www.alitajran.com
LinkedIn:   linkedin.com/in/alitajran
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Set the user properties to retrieve
$Properties = @(
    "id",
    "DisplayName",
    "userprincipalname",
    "PasswordPolicies",
    "lastPasswordChangeDateTime",
    "mail",
    "jobtitle",
    "department"
)

# Retrieve all users with the specified properties
$AllUsers = Get-MgUser -All -Property $Properties | Select-Object -Property $Properties

# Export the data to CSV
$CsvPath = "C:\Temp\PasswordChangeTimeStamp.csv"
$AllUsers | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8

Write-Host "Export completed. CSV saved at $CsvPath" -ForegroundColor Green
