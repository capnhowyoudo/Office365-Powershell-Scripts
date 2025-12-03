# Add email addresses and domains to Safe Senders and Blocked Senders Lists
To add email addresses and domain names to the Safe Senders and Blocked Senders list for a single or all mailboxes, use the Set-MailboxJunkEmailConfiguration PowerShell cmdlet.

# Add email addresses or domains and remove existing Safe Senders list
To create an allow list of trusted senders, add new email addresses to the Safe Senders list, which will remove all existing ones from the list. Use the -TrustedSendersAndDomains parameter in the PowerShell command to add email addresses and domains to the Safe Senders list.

- Create a new Safe Senders list and add trusted senders for a specific mailbox that will also remove all the existing email addresses from the list.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -TrustedSendersAndDomains "o365info.com", "alice@gmail.com"

- Create a new Safe Senders list by adding trusted senders for all mailboxes that will also remove all the existing email addresses and domain names from the list.

      Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -TrustedSendersAndDomains "o365info.com", "alice@gmail.com"

# Add email addresses and domains to existing Safe Senders list
To manage an allow list of trusted senders you can always add email addresses and domain names. Use the -TrustedSendersAndDomains parameter in the PowerShell command to add multiple email addresses and domains to the existing Safe Senders list.

- Add an additional email address and domain name to the current Safe Senders list for a specific recipient without removing any existing trusted senders or domains.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -TrustedSendersAndDomains @{Add = "o365info.com", "alice@gmail.com" }

 - Run the PowerShell command to add an additional email address and domain name to the current Safe Senders list for all mailboxes. It will not remove any existing trusted senders or domains from each Safe Senders list.

        Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -TrustedSendersAndDomains @{Add = "o365info.com", "alice@gmail.com" }

# Add email addresses or domains and remove existing Blocked Senders list
To create a block list of untrusted senders, add new email addresses to the Blocked Senders list, which will remove all existing ones from the list. Use the -BlockedSendersAndDomains PowerShell parameter to add email addresses and domains to the Blocked Senders list.

- Create a new Blocked Senders list and add untrusted senders for a specific mailbox. It will also remove all the existing email addresses and domains from the list.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -BlockedSendersAndDomains "itspam.com", "spam@gmail.com"

- Create a new Blocked Senders list and add untrusted senders for all mailboxes, which will remove all the existing email addresses from the list.

      Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -BlockedSendersAndDomains "itspam.com", "spam@gmail.com"

# Add email addresses and domains to existing Blocked Senders list
You can also manage the block list of untrusted senders by adding an email address and domain to the current Blocked Senders list. It will not remove any existing email addresses or domains from the list.

- Add an email address and domain name to the current Blocked Senders lists for a specific recipient.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -BlockedSendersAndDomains @{Add = "itspam.com", "spam@gmail.com" }

 - Add an additional email address and domain name to the current Blocked Senders lists for all the Exchange recipients. It will not remove any existing untrusted senders or domains from each Blocked Senders list.

Run the PowerShell command to add blocked senders and domains to the existing Blocked Senders list for all mailboxes.

      Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -BlockedSendersAndDomains @{Add= "itspam.com", "spam@gmail.com" }

# Add email addresses or domains and remove existing Safe Senders and Blocked Senders lists
To create new Safe Senders and Blocked Senders lists, you need to add new email addresses, which will remove the existing ones from both lists.

- Add new email addresses and domains to both the Safe Senders and Blocked Senders lists for a specific mailbox, which will remove the existing lists.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -TrustedSendersAndDomains "o365info.com", "alice@gmail.com" -BlockedSendersAndDomains "itspam.com", "spam@gmail.com"

 - Run the PowerShell command below to add email addresses and domains to the Safe Senders and Blocked Senders lists for all mailboxes which will remove the existing lists.

        Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -TrustedSendersAndDomains "o365info.com", "alice@gmail.com" -BlockedSendersAndDomains "itspam.com", "spam@gmail.com"

# Add email addresses or domains to existing Safe Senders and Blocked Senders lists
To manage the current Safe Senders and Blocked Senders list, you can always add new email addresses. It will not remove any email addresses or domains from the existing lists.

- Only add email addresses and domains to both the Safe Senders and Blocked Senders lists for a specific mailbox.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -TrustedSendersAndDomains @{Add = "o365info.com", "alice@gmail.com" } -BlockedSendersAndDomains @{Add = "itspam.com", "spam@gmail.com" }

- Run the PowerShell command below to add email addresses and domains to the Safe Senders and Blocked Senders lists for all mailboxes.

      Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -TrustedSendersAndDomains @{Add = "o365info.com", "alice@gmail.com" } -BlockedSendersAndDomains @{Add = "itspam.com", "spam@gmail.com" }

# Update existing Safe Senders and Blocked Senders lists
You can always update the existing Safe Senders lists and Blocked Senders lists. Manage both lists by removing or adding email addresses or domains for a single and all mailboxes.

- Remove email addresses and domain names from Safe Senders list
  - We would like to remove an email address and domain name from the Safe Senders list from a specific user mailbox.

  - Run the PowerShell command to remove from the Safe Senders list for a single mailbox.

        Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -TrustedSendersAndDomains @{Remove = "alice@gmail.com", "o365info.com" }

 - You can also remove an email address and domain name from the Safe Senders list for all the Exchange recipients.
   - Run the PowerShell command to remove from the Safe Senders list for all mailboxes.

         Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -TrustedSendersAndDomains @{Remove = "alice@gmail.com", "o365info.com" }

# Remove email addresses and domain names from Blocked Senders list
We would like to remove an email address and domain name from the Blocked Senders list of a specific user mailbox.

- Run the PowerShell command to remove from the Blocked Senders list for a single mailbox.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -BlockedSendersAndDomains @{Remove = "spam@gmail.com", "itspam.com" }

- You can also remove an email address and domain name from the Blocked Senders list for all the Exchange recipients.
- Run the PowerShell command to remove from the Blocked Senders list for all mailboxes.

      Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -BlockedSendersAndDomains @{Remove = "spam@gmail.com", "itspam.com" }

- Add and remove email addresses and domains in Safe Senders list
- Run the PowerShell command below to add and remove trusted senders and domains for a specific mailbox.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -TrustedSendersAndDomains @{Remove = "alice@gmail.com", "o365info.com" ; Add = "alice.good@gmail.com", "safedomain.com" }

- Run the PowerShell command below to add and remove trusted senders and domains for all mailboxes.

      Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -TrustedSendersAndDomains @{Remove = "alice@gmail.com", "o365info.com" ; Add = "alice.good@gmail.com", "safedomain.com" }

- Add and remove email addresses and domains in Blocked Senders list
- Run the PowerShell command below to add and remove blocked senders and domains for a specific mailbox.

      Set-MailboxJunkEmailConfiguration -Identity "Amanda.Hansen@m365info.com" -BlockedSendersAndDomains @{Remove = "spam@gmail.com", "itspam.com"; Add = "spam@gmail.com", "itspam.com" }

- PowerShell command to add and remove blocked senders and domains for all mailboxes.

      Get-Mailbox -ResultSize Unlimited | Set-MailboxJunkEmailConfiguration -BlockedSendersAndDomains @{Remove = "spam@gmail.com", "itspam.com"; Add = "junkspam@gmail.com", "junkspam.com" } 


     https://o365info.com/safe-senders-blocked-senders-lists-powershell/
