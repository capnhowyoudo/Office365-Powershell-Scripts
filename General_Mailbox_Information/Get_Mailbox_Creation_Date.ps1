<#
.SYNOPSIS
Displays the creation date of a mailbox.
#>

get-mailbox -id user@youremail.com | select whenCreated
