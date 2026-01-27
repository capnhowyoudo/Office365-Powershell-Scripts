# Enable External Forwarding in Microsoft 365

When connecting Microsoft 365 to Help Scout, you may encounter a security block. By default, Microsoft 365 disables automatic external forwarding to prevent outbound spam.
How to Identify the Issue

If your forwarding isn't working, check your Microsoft 365 inbox for a bounce-back message. You are likely facing this restriction if the email includes the following error:

> :warning: 550 5.7.520 Access denied, Your organization does not allow external forwarding.

Why This Happens

Although the error message can be confusing, it does not mean Help Scout rejected your mail. Instead, Microsoft’s internal security policy blocked the message before it ever reached Help Scout.
The Solution

To resolve this, your Microsoft 365 Administrator must update your outbound spam protection policies to permit external forwarding for your specific email addresses.

# Enable Automatic External Forwarding for All Mailboxes

Log in to Microsoft 365 Defender as a Microsoft 365 administrator and choose Email & collaboration > Policies & rules > Threat policies > Anti-spam policies or head directly to the Anti-spam settings page here: https://security.microsoft.com/antispam 

If you do not see those options or no policies display on that page, the Microsoft 365 user you have used to log in does not have sufficient permissions to make these changes. Make sure you are logging in as an administrator for your account.  

> :information_source: Note that the policies you see in your own admin may differ from those shown here, as these are only the default policies.

<img width="854" height="380" alt="image" src="https://github.com/user-attachments/assets/70796e68-0949-41b0-a8f5-fe4c85833a98" />

>

Click on Anti-spam outbound policy (Default) and scroll down to click the Edit protection settings link at the bottom of the sidebar.

<img width="480" height="635" alt="image" src="https://github.com/user-attachments/assets/658f087e-249c-4fea-a6bd-fc206d572604" />

>

Find the section called Forwarding Rules, and the dropdown list called Automatic Forwarding Rules. Pull that list down and choose On - Forwarding is enabled. Click Save at the bottom.

<img width="749" height="480" alt="image" src="https://github.com/user-attachments/assets/68dd15ec-d5ed-4894-b501-184f751da1ca" />

# Enable Automatic External Forwarding for Individual Mailboxes

Log in to Microsoft 365 Defender as a Microsoft 365 administrator and choose Email & collaboration > Policies & rules > Threat policies > Anti-spam policies or head directly to the Anti-spam settings page here: https://security.microsoft.com/antispam 

If you do not see those options or no policies display on that page, the Microsoft 365 user you have used to log in does not have sufficient permissions to make these changes. Make sure you are logging in as an administrator for your account.  

> :information_source: Note that the policies you see in your own admin may differ from those shown here, as these are only the default policies.

<img width="854" height="380" alt="image" src="https://github.com/user-attachments/assets/09b2c956-eb34-4295-84b1-60e89b905986" />

>

Click + Create policy and choose Outbound. 

<img width="477" height="223" alt="image" src="https://github.com/user-attachments/assets/5c77ff3e-bf61-4187-af4b-eb3399665ac2" />

>

Give your new outbound spam filter policy a Name and Description.

Click Next and search to find the user account you want to allow to forward, i.e. the email account that you are forwarding to Help Scout, which will display under the Users field after you select it. 

Click Next again, scroll down to the Forwarding rules section, and click the dropdown under Automatic forwarding rules. Choose On - Forwarding is enabled, then click Next.  

<img width="750" height="514" alt="image" src="https://github.com/user-attachments/assets/5c42486b-7d16-4fcc-ac3c-d7259364eb28" />

Review the settings on the last screen and click Create to create your new outbound policy for the specified user(s). 
