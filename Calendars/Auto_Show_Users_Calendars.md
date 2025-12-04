For a manager's calendar to automatically show the availability of their direct reports, each report's user account must have the Manager field set. You'll need to update this field either in your local Active Directory for users synced via Azure AD Connect, or in the Microsoft 365 admin center for cloud-managed users.

# To set the Manager attribute on an on-premises Active Directory server, follow these steps:

1. In Active Directory Users and Computers, open the Properties dialog box of the user account.
2. On the Organization tab, under the Manager area, select Change.
3. Browse the directory to find the user's manager, and then select the manager.
4. Select OK
5. Force a manual sync with Entra-Connect or wait 30 minutes.

# To set the Manager attribute in Exchange Online, follow these steps:

1. In the Microsoft 365 admin center, select Users, and then select Active users.
2. Select the user's name, and then select Mail.
3. In the More settings section, select Edit Exchange properties, and then select organization.
4. Next to Manager, select Browse.
5. Select the user's manager, and then select OK.
6. Select Save, and then select OK.

# Result

<img width="536" height="237" alt="image" src="https://github.com/user-attachments/assets/4bc5e348-d369-461d-94e6-4ff496b77790" />

