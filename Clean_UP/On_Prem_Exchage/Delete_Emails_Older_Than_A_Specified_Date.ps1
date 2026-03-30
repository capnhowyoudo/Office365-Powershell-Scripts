<#
.SYNOPSIS
Deletes mailbox items older than a specified date in batches.

.DESCRIPTION
This script repeatedly runs a mailbox search to find and delete items received before
January 1, 2021. It continues looping until no more matching items are found.

.NOTES
User: Generic User

DISCLAIMER:
This action is PERMANENT and cannot be undone. All deleted mailbox items will be irrecoverably removed.
Ensure you have verified the scope and have appropriate backups or retention policies in place
before executing this script.
#>

while ($true) {
    $results = Search-Mailbox -Identity "John Jones" -SearchQuery 'Received<2021-01-01' -DeleteContent -Force
    Write-Host "Deleted $($results.ResultItemsCount) items..." -ForegroundColor Cyan
    if ($results.ResultItemsCount -eq 0) { break }
}
