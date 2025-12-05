# How to Configure High Volume Email for Microsoft 365

If your organization sends a lot of emails internally, you can run into a limit, which can cause delays and problems. High Volume Email in Microsoft 365 is a service that allows an organization to send high volumes of internal messages without any rate limits. In this article, you will learn how to configure High Volume Email in Exchange Online.

# Mail (HVE)

High Volume Email in Microsoft 365 is mainly for organizations that want to send many emails internally with Exchange Online and a limited number of external emails. To set it up, you need to create an HVE account before you can start sending mass emails.

The table below shows the limits for the standard Microsoft 365 mailbox vs. HVE mailbox.


| | Standard Microsoft 365 mailbox | High Volume Email (HVE) |
| :--- | :--- | :--- |
| Max of internal recipients | 10,000 recipients per day | 100,000 recipients per day |
| Message rate limit | 30 messages per minute | No limit |
| Accounts per tenant | - | 20 accounts |
| Max. of external recipient | - | 2,000 recipients per day |

# Create HVE account with PowerShell

> :heavy_exclamation_mark: An HVE account CANNOT send emails to external users. HVE accounts are intended for internal use only, sending emails to users within the same domain or to other domains that exist within the same tenant. An HVE account does not require an active license.

To configure a HVE account with PowerShell, run the commands below.

1. Connect to the Exchange Online PowerShell module.

       Connect-ExchangeOnline

2. Type the Name and Primary SMTP address in line 2.

> :information_source: You do not need to enter the password directly in the cmdlet. After you run the command, you will be prompted to enter the password securely.
> The only parameters you need to modify are:
>
> 1. Name
>
> 2. PrimarySmtpAddress

        $NewPassword = Read-Host -AsSecureString "Enter your password"
        New-MailUser -HVEAccount -Name "HVE02" -Password $NewPassword -PrimarySmtpAddress "HVE02@m365info.com"

3.  Enter a complex password for your HVE Account when prompted.

# Enable SMTP Basic Authentication

4. To use High Volume Email for Microsoft 365 with SMTP Basic Authentication, you need to follow the steps below:

Use the New-AuthenticationPolicy cmdlet to create a new authentication policy that allows SMTP Basic Authentication in your organization with the PowerShell command below.

> :information_source: This setting does not need to be modified unless you prefer to use a custom policy name
	
    New-AuthenticationPolicy -Name "High Volume Email" -AllowBasicAuthSmtp

5. Then run the PowerShell command below to set the HVE account (HVE01@m365info.com) to the authentication policy you just created.

> :information_source: Update HVE01@m365info.com to match the HVE account you created in Step 2. Also update "High Volume Email" if you chose to rename the policy in the previous step. If you did not change the policy name, you can leave it as-is.
  
    Set-User "HVE01@m365info.com" -AuthenticationPolicy "High Volume Email" -Confirm:$false

6. By default, when you create or change the authentication policy assignment on users or update the policy, the changes take effect within 24 hours. 

If you want the policy to take effect within 30 minutes, run the PowerShell command below.

> :information_source: Replace HVE01@m365info.com with the email address you created in Step 2 to ensure the command applies to the correct HVE account.

    Set-User -Identity "HVE01@m365info.com" -STSRefreshTokensValidFrom $([System.DateTime]::UtcNow) -Confirm:$false

# Disable Security Defaults

You must Disable Security Defaults if you don’t use Conditional Access policies in your organization if enabled.

If your organization is using Conditional Access policies, the Security Defaults are disabled by default. Therefore, you must see if the Conditions > Client apps are not configured or make sure to exclude the HVE account from the policy

<img width="1070" height="715" alt="image" src="https://github.com/user-attachments/assets/b3d5c64f-a5eb-4fcb-abef-00d35f3ef106" />

# SMTP Authentication details

- Server/Endpoint: smtp-hve.office365.com

- Port: 587

- TLS: STARTTLS

- TLS 1.2 and TLS 1.3 are supported

- Authentication: Username and password

# Send a test email

You can download the SMTP Test Tool from the following location:

https://raw.githubusercontent.com/capnhowyoudo/Lite-Weight-Applications/refs/heads/main/Email_Test_Tool/Test_Email_Tool.exe

The tool will automatically check for the MailKit module. If the module is not installed, it will download and install it from PowerShell Gallery automatically.

Be sure to use the dropdown menu within the tool to select the correct server and change it to smtp-hve.office365.com.

<img width="786" height="733" alt="image" src="https://github.com/user-attachments/assets/3665be30-5fe9-4872-8958-6db2f99efff9" />







