<#
.SYNOPSIS
Displays mailbox and archive sizes along with item counts for all user mailboxes.

.DESCRIPTION
This script retrieves all user mailboxes, including their archive status if applicable. 
It collects the total size and item count for both the primary mailbox and the archive mailbox (if enabled). 
The results are displayed in an interactive Out-GridView window and exported to a CSV file.

.NOTES
- Uses Get-Mailbox to list all mailboxes.
- Uses Get-MailboxStatistics to get size and item count details.
- Archives are only queried if the mailbox has an active archive.
- Exports results to "C:\Temp\MailboxSizes.csv".
#>

$mailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object UserPrincipalName, Identity, ArchiveStatus
$mailboxsizes = @()

foreach ($mailbox in $mailboxes) {

    $objproperties = New-Object PSObject

    $mailboxstats = Get-MailboxStatistics $mailbox.UserPrincipalName | Select-Object TotalItemSize, ItemCount

    Add-Member -InputObject $objproperties -MemberType NoteProperty -Name "UserPrincipalName" -Value $mailbox.UserPrincipalName
    Add-Member -InputObject $objproperties -MemberType NoteProperty -Name "Mailbox Size" -Value $mailboxstats.TotalItemSize
    Add-Member -InputObject $objproperties -MemberType NoteProperty -Name "Mailbox Item Count" -Value $mailboxstats.ItemCount

    if ($mailbox.ArchiveStatus -eq "Active") {
        $archivestats = Get-MailboxStatistics $mailbox.UserPrincipalName -Archive | Select-Object TotalItemSize, ItemCount
        Add-Member -InputObject $objproperties -MemberType NoteProperty -Name "Archive Size" -Value $archivestats.TotalItemSize
        Add-Member -InputObject $objproperties -MemberType NoteProperty -Name "Archive Item Count" -Value $archivestats.ItemCount
    } else {
        Add-Member -InputObject $objproperties -MemberType NoteProperty -Name "Archive Size" -Value "No Archive"
        Add-Member -InputObject $objproperties -MemberType NoteProperty -Name "Archive Item Count" -Value "No Archive"
    }

    $mailboxsizes += $objproperties
}

# Display in grid view
$mailboxsizes | Out-GridView -Title "Mailbox and Archive Sizes"

# Export to CSV
$exportPath = "C:\Temp\MailboxSizes.csv"
$mailboxsizes | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8
Write-Host "✅ Mailbox and archive sizes exported to $exportPath"
