# How to hide users from Global Address List (GAL) in Exchange Online if they are AD Connect synchronized

Hiding User from GAL isn't possible if those are synchronized form On-Premises Active Directory. The local AD is the leading system for all important attributes, like SMTP, UPN and hiding from GAL.

Especially during a cross-tenant migration, you do not want to see not migrated user in the GAL. Those User aren't actively working until their cut-over day.

Since the Exchange Online attribute msExchHideFromAddressLists is an AD on-premises parameter, we have two possible ways hiding user in BME from GAL. 

 - Modify the AD Connect for your teant with a custom rule, by using a extensionAttribute to set the HidefromGAL. In this rule, for users which have an entry in the extensionAttribute, hiding / un-hiding will be controlled by AD Connect
   This is the best option for Cross-Tenant Migration, if you run 2 or more AD Connect system
 
 - We direct modify the AD hide attribute in AD 
    This option isn't the best for cross-tenant migrations

I would recommend the first option. 

# Modifying the AD Connect Role:

1. Open Synchronization Rules Editor:

<img width="698" height="750" alt="image" src="https://github.com/user-attachments/assets/0877460d-fbaa-496d-b284-35e7c9ae9e1f" />

2. Create a new Rule (INBOUND)

<img width="1027" height="789" alt="image" src="https://github.com/user-attachments/assets/74f1e372-eb5a-45a4-9839-a1d67156117c" />

3. Enter the following for the description:

- Name: **Hide user from GAL**
- Description: **If msDS-CloudExtensionAttribute1 attribute is set to HideFromGAL, hide from Exchange Online GAL**
- Connected System: **Your Active Directory Domain Name**
- Connected System Object Type: **user**
- Metaverse Object Type: **person**
- Link Type: **Join**
- Precedence: **50** (this can be any number less than 100.  Just make sure you don't duplicate numbers if you have other custom rules or you'll receive a dead-lock error from SQL Server)

<img width="1199" height="791" alt="image" src="https://github.com/user-attachments/assets/0f103479-28e6-40b4-8ddb-8054ce23a00f" />

Click **Next** > on **Scoping filter** and **Join rules**, those can remain blank

Enter the following Transformation page, click the **Add transformation** button, fill out the form with the values below, and then click Add
FlowType: **Expression**
Target Attribute: msExchHideFromAddressLists
Source:

    IIF(IsPresent([msDS-cloudExtensionAttribute1]),IIF([msDS-cloudExtensionAttribute1]="HideFromGAL",True,False),NULL)

<img width="601" height="400" alt="image" src="https://github.com/user-attachments/assets/8c3d76da-b0f6-4dfd-a5f7-4250765d2d17" />
