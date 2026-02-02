# Downgrade Office365 Editions

1. Determine the build number of Office you need to revert to by checking the Office update history page https://learn.microsoft.com/en-us/officeupdates/update-history-microsoft365-apps-by-date For example, we will be using Version 2002 (Build 12527.20278).
2. Download and extract the Office Deployment Tool https://www.microsoft.com/en-us/download/details.aspx?id=49117 to a new folder called Office Install on the Cdrive; this creates the setup.exe file along with a few test configuration XML files:
<img width="1169" height="552" alt="image" src="https://github.com/user-attachments/assets/86812c71-ba36-4496-b1a9-02d2aac4e517" />
3. Open Notepad and copy the following into a new document:

        <Configuration>
        <Updates Enabled="TRUE" TargetVersion="16.0.12527.20278" />
        </Configuration>
  
Save that in the same folder as above, naming it config.xml and save as type All Files.

<img width="971" height="540" alt="image" src="https://github.com/user-attachments/assets/63c94438-b246-459f-9f14-c8c9ce5d8acd" />

4. Close all Office programs, like Word, Excel, Outlook, etc.

:information_source: If you are on a server, advise the other users of the server to close all Office programs as well.

5. Open cmd prompt as administrator and type the below:

        cd C:\Office Install
   
Press Enter

Then type

        setup.exe /configure config.xml

Press Enter

<img width="808" height="349" alt="image" src="https://github.com/user-attachments/assets/1c19c0df-7074-4085-b815-403b21b8feb9" />

6. An Office box will show briefly and disappear. You can close the cmd prompt once it closes.
7. open Word and go to Account > Office Updates. Click Update Now.

<img width="577" height="690" alt="image" src="https://github.com/user-attachments/assets/e446ea0e-3aee-4eb9-9e01-be016c88757f" />

8. Wait a five minutes, then reboot your computer

9. When it has restarted, open Word again and go back to Office Updates.
Now you can disable updates to prevent this from installing itself again!

<img width="984" height="645" alt="image" src="https://github.com/user-attachments/assets/2cbc2340-f13d-48dd-a763-f1631aa28932" />


