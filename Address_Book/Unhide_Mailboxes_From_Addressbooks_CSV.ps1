<# 
.SYNOPSIS
Bulk-unhide mailboxes from the address list using a CSV file.

.DESCRIPTION
This script imports a CSV file containing a list of mailbox email addresses and updates 
each mailbox so it is no longer hidden from the address book.  

The CSV file must contain a single column named **Email**, with each row listing the 
SMTP address of the mailbox to modify. Example CSV format:

    Email
    user1@domain.com
    user2@domain.com
    user3@domain.com

#>

Import-Csv C:\Temp\PSHidden.csv | ForEach-Object { Set-Mailbox -Identity $_.Email -HiddenFromAddressListsEnabled $false }
