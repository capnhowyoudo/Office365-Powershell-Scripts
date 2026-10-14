<#
.SYNOPSIS
Creates the "Marketing Team" distribution group in Exchange Online.

.DESCRIPTION
Connects to Exchange Online and creates a distribution group named "Marketing Team"
with the alias "marketing" and the primary SMTP address marketing@contoso.com.
The group is assigned two owners and three initial members. Sender authentication
is disabled so that external (unauthenticated) senders can email the group.

.NOTES
Requires:
  - The ExchangeOnlineManagement module (Install-Module ExchangeOnlineManagement)
  - An account with permission to create distribution groups (e.g. Recipient Management role)
Replace the contoso.com addresses with your own domain's owners and members.
Setting -RequireSenderAuthenticationEnabled to $false allows external senders and
may increase spam exposure; set it to $true to restrict the group to internal senders.
#>

Connect-ExchangeOnline

New-DistributionGroup `
    -Name "Marketing Team" `
    -DisplayName "Marketing Team" `
    -Alias "marketing" `
    -PrimarySmtpAddress "marketing@contoso.com" `
    -Type Distribution `
    -ManagedBy "owner1@contoso.com","owner2@contoso.com" `
    -Members "user1@contoso.com","user2@contoso.com","user3@contoso.com" `
    -RequireSenderAuthenticationEnabled $false
