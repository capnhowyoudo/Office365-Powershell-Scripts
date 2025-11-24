<#
.SYNOPSIS
Exports the current members of a Dynamic Distribution Group (DDG) to a CSV file.

.DESCRIPTION
This script connects to Exchange Online, retrieves a specified Dynamic Distribution Group,
calculates its current members based on the RecipientFilter or LdapRecipientFilter, 
and exports their details to a CSV file.

.NOTES
- Requires Exchange Online PowerShell module.
- Make sure you have permissions to access the DDG and execute Get-Recipient.
- The output CSV contains the following properties: DisplayName, PrimarySmtpAddress, RecipientType, Company, Department, Title.
- Generic emails are used for documentation purposes.
- The CSV file is saved to C:\Temp by default. The folder must exist or be created beforehand.
#>

# -----------------------------------------------------------
# SCRIPT CONFIGURATION
# -----------------------------------------------------------

# Specify the name of your Dynamic Distribution Group
$DDGName = "allstaff@domain.com"

# Specify the path for the output file
$ExportPath = "C:\Temp\$($DDGName)_Members.csv"

# -----------------------------------------------------------

# 1. Connect to Exchange Online
Write-Host "Connecting to Exchange Online..."
try {
    Connect-ExchangeOnline -ShowProgress $true
} catch {
    Write-Error "Failed to connect to Exchange Online. Ensure the module is installed."
    exit 1
}

# 2. Retrieve the Dynamic Distribution Group and its filter
Write-Host "Retrieving Dynamic Distribution Group '$DDGName'..."
try {
    $DDG = Get-DynamicDistributionGroup -Identity $DDGName -ErrorAction Stop
    $RecipientFilter = $DDG.RecipientFilter
    $IncludedRecipients = $DDG.IncludedRecipients
    $LdapFilter = $DDG.LdapRecipientFilter

    if (-not $RecipientFilter -and -not $LdapFilter) {
        Write-Error "The specified group '$DDGName' either does not exist or does not have a recipient filter defined."
        Disconnect-ExchangeOnline -Confirm:$false
        exit 1
    }

} catch {
    Write-Error "Error retrieving group: $($_.Exception.Message)"
    Disconnect-ExchangeOnline -Confirm:$false
    exit 1
}

Write-Host "Group Filter (RecipientFilter): $RecipientFilter"
Write-Host "Group Filter (LdapFilter): $LdapFilter"

# 3. Use Get-Recipient to calculate and retrieve the current members
Write-Host "Calculating and retrieving current members based on the filter..."

# Use the -RecipientFilter parameter with the filter found on the DDG
$Members = try {
    if ($RecipientFilter) {
        Get-Recipient -RecipientPreviewFilter $RecipientFilter -ResultSize Unlimited -ErrorAction Stop
    } elseif ($LdapFilter) {
        Get-Recipient -LdapRecipientFilter $LdapFilter -ResultSize Unlimited -ErrorAction Stop
    } else {
        throw "No valid recipient filter found on the group."
    }
} catch {
    Write-Error "Error calculating members using the filter: $($_.Exception.Message)"
    $Members = @() # Set to empty array to prevent script failure
}

# 4. Select properties and Export Data
if ($Members.Count -gt 0) {
    Write-Host "Found $($Members.Count) members. Exporting to CSV..."
    
    $Report = $Members | Select-Object `
        DisplayName,
        PrimarySmtpAddress,
        RecipientType,
        Company,
        Department,
        Title
    
    # Create folder if it doesn't exist
    if (-not (Test-Path "C:\Temp")) { New-Item -Path "C:\Temp" -ItemType Directory | Out-Null }

    $Report | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "Export complete! File saved at: $ExportPath"
} else {
    Write-Host "No members found for this Dynamic Distribution Group."
}

# 5. Disconnect from Exchange Online
Write-Host "Disconnecting from Exchange Online..."
Disconnect-ExchangeOnline -Confirm:$false
