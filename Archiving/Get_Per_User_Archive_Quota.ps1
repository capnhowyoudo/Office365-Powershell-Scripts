<#
.SYNOPSIS
Displays the mailbox name along with archive-related quota information for a specified mailbox.
#>

Get-Mailbox <Name> | FL Name,Archive*Quota
