# Understanding How the MX Record can work with Scan to Email

Microsoft 365 accepts inbound email on port 25 because that's the standard SMTP port used for mail delivery between mail servers. When a device (such as a copier, scanner, or multifunction printer) sends email directly to your Microsoft 365 domain, it can look up the domain's MX record in DNS and connect to the Exchange Online mail server listed in that MX record over port 25.

This method works because:

The MX record identifies the Microsoft 365 mail server responsible for receiving mail for your domain.
Exchange Online allows SMTP relay from approved sources to the MX endpoint on port 25.
The connection is typically authenticated by the sending device's public IP address rather than a username/password.
It avoids issues with SMTP AUTH being disabled or modern authentication requirements that many scanners cannot support.
Microsoft designed this "Direct Send" / "SMTP Relay" scenario specifically for devices like copiers, scanners, and line-of-business applications.

The main requirement is that the sending device must either:

Send only to internal recipients in your Microsoft 365 tenant (Direct Send), or
Be configured as an approved SMTP relay source using a connector and a static public IP (SMTP Relay).

In short: the MX record points to Microsoft's inbound mail servers, and those servers listen on port 25 for standard SMTP traffic, allowing scanners and copiers to send email without traditional mailbox authentication when configured correctly.

# Requirements for Scan-to-Email Using Microsoft 365 MX Record (Port 25)

To support scan-to-email functionality using Microsoft 365 Direct Send or SMTP Relay, the following requirements must be met:

Outbound TCP Port 25 Must Be Open
- The client's firewall, security appliance, ISP, and network policies must allow outbound SMTP traffic on TCP port 25.
- The scanning device or mail relay server must be able to establish a connection to the Microsoft 365 MX record endpoint over port 25.

DNS Resolution
- The scanning device or relay server must be able to resolve the organization's Microsoft 365 MX record through DNS.

Internet Connectivity
- The device must have direct internet access or a permitted path through the organization's firewall to reach Microsoft 365 mail servers.

Static Public IP (SMTP Relay Only)
- If Microsoft 365 SMTP Relay is being used, the client must provide a static public IP address that can be configured within the Microsoft 365 connector.

Firewall and Security Exceptions
-Any outbound filtering, SMTP inspection, or security controls must permit communication to Microsoft 365 Exchange Online endpoints on port 25.

> :information_source: Important: If outbound TCP port 25 is blocked by the client's firewall, internet service provider, or security policies, Microsoft 365 Direct Send and SMTP Relay methods will not function, and scan-to-email delivery will fail.

# Verifying That Port 25 Is Open

To verify that outbound SMTP traffic on port 25 is allowed, log on to a server or workstation within the client's organization and run the provided PowerShell test script located [Here](https://github.com/capnhowyoudo/Office365-Powershell-Scripts/blob/main/MX_Relay/Test_SMTP_Port_25.ps1).

Before running the script, update the following parameters:

* `$MXRelay`
* `$From`
* `$To`
* `$Ehlodomain`

<img width="1104" height="226" alt="image" src="https://github.com/user-attachments/assets/2b11a512-7ec6-4b50-b218-70d43ca21ad1" />


## Obtaining the Microsoft 365 MX Record

### Method 1 – Microsoft 365 Admin Center

1. Sign in to the Microsoft 365 Admin Center (`https://admin.microsoft.com`).
2. Navigate to **Settings** → **Domains**.
3. Select the domain that will be used for Scan-to-Email.
4. Open the **DNS Records** tab.
5. Locate the **MX Record** entry.

Microsoft will display the exact MX record value assigned to the domain.

Example:

```text
yourdomain-com.mail.protection.outlook.com
```

### Method 2 – PowerShell

Connect to Exchange Online and run the following commands:

```powershell
Connect-ExchangeOnline
```
### Get Accepted Domains and MX Records

```powershell
Get-AcceptedDomain | Select-Object DomainName, @{N="MX";E={"$($_.DomainName.Replace('.', '-')).mail.protection.outlook.com"}}
```

This command will display the calculated Microsoft 365 MX record for each accepted domain.

> **Important:** Be sure to use the primary domain that will be configured for Scan-to-Email. The MX record entered in the test script must match the domain that will be used for sending email from the device.

## Expected Result

If the script successfully connects to the Microsoft 365 MX record over port 25 and sends a test message, outbound SMTP traffic is permitted and the network is capable of supporting Microsoft 365 Direct Send or SMTP Relay.

The following example shows a successful connection test with port 25 accessible.

<img width="1059" height="566" alt="image" src="https://github.com/user-attachments/assets/842e27fd-540b-4ed4-805a-a41f21202288" />

If the connection fails, verify that:

* Outbound TCP port 25 is allowed through the client's firewall.
* The ISP is not blocking port 25.
* DNS resolution is functioning correctly.
* The MX record is configured correctly.






