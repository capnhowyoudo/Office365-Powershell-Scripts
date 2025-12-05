<#
.SYNOPSIS
Create guest users accounts and sends guest invitations to Microsoft 365 users listed in a CSV file.

.DESCRIPTION
This script connects to Microsoft Graph, reads user information from a CSV file, including display names and email addresses,
and sends Microsoft 365 guest invitations using the Microsoft Graph PowerShell module.
It optionally allows sending a customized message to each invited user and redirects
them to a specified URL upon acceptance.

.NOTES
Author: capnhowyoudo
Date: 2025-11-25
Requires: Microsoft.Graph PowerShell Module

CSV Format:
The CSV file must have the following columns:
- DisplayName  : The full name of the guest user
- EmailAddress : The email address of the guest user

Example CSV content:
DisplayName,EmailAddress
John Doe,john.doe@example.com
Jane Smith,jane.smith@example.com

Example Usage:
Create_Bulk_Guest_Users_With_Invite.ps1
#>

# --- Connect to MSGraph ---

Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All

# --- Configuration ---
$csvPath = "C:\Scripts\Guests.csv"  # <--- Update this with the path to your CSV file
$redirectUrl = "https://myapplications.microsoft.com" # <--- The URL the user is redirected to after accepting the invite

# --- Optional: Custom Invitation Message ---
$customMessageBody = "Hello! You have been invited to collaborate with our organization in Microsoft 365. Please accept this invitation to gain access to our shared resources."

# Use the correct type and property name
$messageInfo = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphInvitedUserMessageInfo
$messageInfo.CustomizedMessageBody = $customMessageBody

# --- Import CSV and Send Invitations ---
Write-Host "Importing users from CSV: $csvPath"

try {
    # Import the CSV data
    $guestUsers = Import-Csv -Path $csvPath

    Write-Host "Processing $($guestUsers.Count) users..."
    
    # Loop through each user in the CSV
    foreach ($user in $guestUsers) {
        $displayName = $user.DisplayName
        $email = $user.EmailAddress
        
        Write-Host "Sending invitation to: $($displayName) ($($email))..."
        
        # --- FIX APPLIED HERE ---
        # Changed -InvInvitedUserMessageInfo to -InvitedUserMessageInfo
        New-MgInvitation -InvitedUserEmailAddress $email `
            -InvitedUserDisplayName $displayName `
            -InviteRedirectUrl $redirectUrl `
            -SendInvitationMessage:$true `
            -InvitedUserMessageInfo $messageInfo  # <--- CORRECTED PARAMETER
        # ------------------------

        Write-Host "Invitation sent successfully to $($email)." -ForegroundColor Green
    }
    
    Write-Host "---"
    Write-Host "All invitations processed." -ForegroundColor Yellow

} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
