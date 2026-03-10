<#
.SYNOPSIS
Retrieves mail-enabled public folders and displays key email properties.

.DESCRIPTION
This command queries Exchange for all mail-enabled public folders and returns
their name, primary SMTP address, and alias. This helps administrators review
which public folders are mail-enabled and what email addresses are assigned
to them.

.NOTES
Generic example for listing mail-enabled public folders.
#>

# Retrieve all mail-enabled public folders and display name, primary SMTP address, and alias
Get-MailPublicFolder | Select-Object Name, PrimarySmtpAddress, Alias
