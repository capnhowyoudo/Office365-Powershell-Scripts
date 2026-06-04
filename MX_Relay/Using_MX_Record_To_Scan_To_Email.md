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

# How to Find Your Public IP Using ipcow.com
Step 1 — Open a Browser
On a computer connected to the same network as your scanner, open any web browser (Chrome, Edge, Firefox)

Step 2 — Go to the Site
Type in the address bar:
www.ipcow.com
Press Enter

Step 3 — Your IP is Displayed
Your public IP address will be shown at the top of the page automatically — no searching or clicking needed. It will look something like:

Your IP: 203.0.113.10

Step 4 — Write It Down
Copy or note the IP address exactly as shown

> ⚠️ Important Tips
>
>  Must be done from the scanner's network — if you check from a phone on cellular data or a VPN, you'll get the wrong IP If you have multiple locations, check from each site separately as each will have a different public IP If the IP shown is different from 75.149.202.49 already in your connector, that's likely why scans are going to junk — the connector IP won't match and you'll need to update it

# Creating an Inbound Connector in Microsoft 365

---

## Before You Begin — Check for an Existing Connector

Before creating a new connector, verify one does not already exist:

- Go to [admin.exchange.microsoft.com](https://admin.exchange.microsoft.com)
- Navigate to **Mail flow** → **Connectors**
- Look for any existing connector named **Scan to Email Relay** or similar
- If one exists, confirm the IP address listed matches your current public IP before creating a new one

> ⚠️ **Do not create a duplicate connector.** If one already exists with the correct IP, skip this guide and proceed to the next step.

---

## Step 1 — Sign into Exchange Admin Center

- Go to [admin.exchange.microsoft.com](https://admin.exchange.microsoft.com)
- Sign in with your admin credentials

---

## Step 2 — Navigate to Connectors

- On the left menu click **Mail flow**
- Click **Connectors**
- Click **+ Add a connector**

---

## Step 3 — Set the Connection Type

- Under **Connection from** select **Your organization's email server**
- Under **Connection to** select **Office 365**
- Click **Next**

---

## Step 4 — Name Your Connector

- **Name:** `Scan to Email Relay`
- **Description:** `Inbound connector for scanner/MFP relay`
- Make sure **Turn it on** is checked
- Click **Next**

---

## Step 5 — Identify the Sending Server

- Select **"By verifying that the sender's IP address matches one of these IP addresses"**
- Click **+** to add your IP address
- Enter your public IP:

```text
203.0.113.10
```

- Click **Save** then **Next**

---

## Step 6 — Security Restrictions

- Select **"None — do not use transport layer security (TLS)"** if your scanner does not support TLS
- If your scanner supports TLS select **"Any digital certificate, including self-signed certificates"**
- Click **Next**

---

## Step 7 — Review Settings

Confirm the summary shows the following before proceeding:

| Field | Value |
|---|---|
| From | Your organization's email server |
| To | Office 365 |
| IP Address | Your public IP |

- Click **Create connector**

---

## Step 8 — Confirm It's Active

- Back on the Connectors page confirm the new connector shows **Status: On**
- Allow **15–30 minutes** for it to take effect

---

> ℹ️ **After Creating the Connector**
> The connector alone identifies where mail is coming from but does not bypass junk filtering.
> Proceed to the next step to create the SCL -1 Mail Flow Rule if emails continue to go to junk.

# Add the IP to the Connection Filter Policy

This is separate from "Allowed senders/domains" — it works at the IP level before content filtering even runs.

---

## Method 1 — GUI (security.microsoft.com)

1. Go to [security.microsoft.com](https://security.microsoft.com)
2. Navigate to **Email & Collaboration** → **Policies & Rules** → **Threat Policies** → **Anti-spam**
3. Click **Connection filter policy (Default)**
4. Click **Edit connection filter policy**
5. Under **Always allow messages from the following IP addresses or address ranges**, click **+** and add your public IP
6. Click **Save**

---

## Method 2 — PowerShell

Use this method if the Connection Filter Policy is not visible in the UI.

### Add the IP

```powershell
Set-HostedConnectionFilterPolicy -Identity Default -IPAllowList @{Add="YOUR.IP.ADDRESS"}
```

### Verify It Was Added

```powershell
(Get-HostedConnectionFilterPolicy -Identity Default).IPAllowList
```

---

> **Note:** This setting works at the IP level before content filtering runs,
> which is why it is more effective than using the Allowed senders/domains list.

# Create the SCL -1 Mail Flow Rule

> **Note:** Only proceed with this step if emails are still going to junk after completing the
> previous steps. Allow **15–30 minutes** for the previous changes to take effect before proceeding.

---

## Step 1 — Get to Exchange Admin Center

Go to [admin.exchange.microsoft.com](https://admin.exchange.microsoft.com)

---

## Step 2 — Navigate to Rules

**Mail flow** → **Rules** → **+ Add a rule**

---

## Step 3 — Choose Rule Type

Select **"Modify the message properties"** from the dropdown list

---

## Step 4 — Name the Rule

**Name:** `Scanner Relay Bypass`

---

## Step 5 — Set the Condition

- **Apply this rule if:** `The sender` → **IP address is in any of these ranges or exactly matches**
- Enter your public IP:

```text
203.0.113.10
```

- Click **Add** then **Save**

---

## Step 6 — Set the Action

**Do the following:** `Modify the message properties` → **Set the spam confidence level (SCL) to** → `-1`

---

## Step 7 — Finish

- Leave exceptions blank
- Set **Mode** to `Enforce`
- Click **Next** then **Finish**
- Confirm the rule shows as **Enabled**

---

> **Note:** Allow up to **30 minutes** for this rule to propagate before testing.
> SCL -1 tells Exchange to bypass junk filtering entirely for mail coming from your scanner.


