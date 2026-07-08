# Setting Up App-Only Access for Mailbox Reporting Scripts

Here's the full walkthrough for setting up app-only access so this script (and any future admin scripts) can read any mailbox in the tenant without per-mailbox grants.

## 1. Register the app

1. Go to [entra.microsoft.com](https://entra.microsoft.com) (or `portal.azure.com` > **Microsoft Entra ID**).
2. **App registrations** > **New registration**.
3. Name it something like `Mailbox-Reporting-Script`.
4. Supported account types: leave the default (**Accounts in this organizational directory only**).
5. Redirect URI: leave blank — not needed for this.
6. Click **Register**.
7. On the app's **Overview** page, copy and save:
   - **Application (client) ID** → this is your `-AppId`
   - **Directory (tenant) ID** → this is your `-TenantId`

## 2. Add the API permission

1. In the app, go to **API permissions** > **Add a permission**.
2. Choose **Microsoft Graph**.
3. Choose **Application permissions** (not Delegated — this is the key part that lets it read any mailbox).
4. Search for `Mail.Read`, check it, click **Add permissions**.
5. Back on the API permissions page, click **Grant admin consent for [your org]** > confirm.
   - You need **Global Admin** or **Privileged Role Admin** to do this step.
   - The status should now show a green checkmark next to `Mail.Read`.

## 3. Create a certificate

You need a certificate rather than a client secret for the `-CertificateThumbprint` parameter. Easiest way is to generate a self-signed one locally in PowerShell. The public key will be exported to `C:\temp\MailboxReportingScript.cer` — this is the file you'll upload to the app registration in Step 4.

```powershell
$cert = New-SelfSignedCertificate -Subject "CN=MailboxReportingScript" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeySpec KeyExchange -KeyLength 2048 -NotAfter (Get-Date).AddYears(2)

# Export the public key (.cer) to upload to Entra ID
Export-Certificate -Cert $cert -FilePath "C:\temp\MailboxReportingScript.cer"

# Note the thumbprint - you'll need this for the script
$cert.Thumbprint
```

This installs the certificate (with its private key) into your current user's certificate store automatically — that's where `Connect-MgGraph -CertificateThumbprint` will look for it.

## 4. Upload the certificate to the app

1. Back in the app registration, go to **Certificates & secrets** > **Certificates** tab > **Upload certificate**.
2. Upload the `.cer` file you exported in step 3.
3. Click **Add**.

## For future use

Once the app is registered and the certificate is uploaded, keep these three values handy — they're what the script (and any future admin scripts) will need to authenticate:

```powershell
-AppId "<Application (client) ID from step 1>" `
-TenantId "<Directory (tenant) ID from step 1>" `
-CertificateThumbprint "<thumbprint from step 3>"
```
