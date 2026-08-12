<#
.SYNOPSIS
    Exports all email addresses (aliases) for mail-enabled public folders to a CSV file.

.DESCRIPTION
    Retrieves all mail-enabled public folders using Get-MailPublicFolder, then expands
    each folder's EmailAddresses collection so that every SMTP address (primary and
    secondary/alias) is written out as its own row. For each address, the script records
    the folder name, alias, address type (SMTP/smtp), the email address itself, and
    whether it is the primary address (case-sensitive match on 'SMTP'). Results are
    sorted by folder name and then by primary status (descending, so primary addresses
    appear first), and exported to a UTF8-encoded CSV file.

.NOTES
    File Name   : Export-MailPublicFolderAliases.ps1
    Requires    : Exchange Online PowerShell module (or on-prem Exchange Management Shell),
                  connected session with permissions to run Get-MailPublicFolder.
    Output      : C:\Temp\MailPublicFolders_AllAliases.csv
                  (Ensure C:\Temp exists or update the -Path value below.)
    IsPrimary   : Determined via a case-sensitive comparison ($_.PrefixString -ceq 'SMTP').
                  Uppercase 'SMTP' = primary address; lowercase 'smtp' = secondary/alias.
#>

Get-MailPublicFolder -ResultSize Unlimited | ForEach-Object {
    $mpf = $_
    $mpf.EmailAddresses | ForEach-Object {
        [PSCustomObject]@{
            Name         = $mpf.Name
            Alias        = $mpf.Alias
            AddressType  = $_.PrefixString.TrimEnd(':')
            EmailAddress = $_.SmtpAddress
            IsPrimary    = ($_.PrefixString -ceq 'SMTP')
        }
    }
} | Sort-Object Name, IsPrimary -Descending |
    Export-Csv -Path "C:\Temp\MailPublicFolders_AllAliases.csv" -NoTypeInformation -Encoding UTF8
