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

Now perform an initial sync

    Start-ADSyncSyncCycle -PolicyType Initial

<img width="1203" height="272" alt="image" src="https://github.com/user-attachments/assets/5e5e74df-3a0b-4dce-98d4-2af331011c17" />

# Hide the user from AD by setting the attribute

<img width="1128" height="795" alt="image" src="https://github.com/user-attachments/assets/45813d79-1584-455d-82df-0eb5b9fa9350" />

Select the Attributes Editor tab, find **msDS-cloudExtensionAttribute1** and enter the value **HideFromGAL**

:information_source: (Note: The value must be exactly the same as defined in the AD Connect Rule, case sensitive), click OK and OK to close out of the editor. 

<img width="602" height="534" alt="image" src="https://github.com/user-attachments/assets/97e51a2e-7978-452c-81bd-d439ef1e55af" />

Continue with a AD Connect DELTA Sync:

    Start-ADSyncSycnCycle -PolicyType Delta

<img width="1203" height="163" alt="image" src="https://github.com/user-attachments/assets/8b6276ab-b56a-4f0c-856d-a81a37399428" />

Continue with the Export from CUSTOMEDOMAIN.onmicrosoft.com and verify the Update. There must be a count of min. 1, the user where the Attribute was changed

<img width="1203" height="948" alt="image" src="https://github.com/user-attachments/assets/12430a97-2f7d-4deb-87f4-cb52de7399f4" />

Select the user account that is listed and click **Properties**.  On the **Connector Space Object Properties**, you should see Azure AD Connect triggered an **add** to Azure AD to set **msExchHideFromAddressLists** set to true

<img width="1114" height="908" alt="image" src="https://github.com/user-attachments/assets/592190dc-bff9-4bc8-a808-a674bd7a602d" />

