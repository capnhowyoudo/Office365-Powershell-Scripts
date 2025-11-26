<#
.SYNOPSIS
Force sign-out, block sign-in, reset passwords, and disable devices for Microsoft 365 users.

.DESCRIPTION
This script connects to Microsoft Graph
This script allows administrators to reset passwords, disable devices, sign out users from all sessions,
and block sign-in for specific users or all users in Microsoft 365 using Microsoft Graph.

.LINK
www.alitajran.com/force-sign-out-users-microsoft-365/

.NOTES
Written by: ALI TAJRAN
Website:    www.alitajran.com
LinkedIn:   linkedin.com/in/alitajran
Output:     Actions applied directly in Microsoft 365 tenant.

.PARAMETER All
Applies the selected actions to all users in the tenant.

.PARAMETER ResetPassword
Resets the password for the selected users and forces a change at next sign-in.

.PARAMETER DisableDevices
Disables all registered devices for the selected users.

.PARAMETER SignOut
Revokes all active sessions for the selected users.

.PARAMETER BlockSignIn
Blocks the selected users from signing in to Microsoft 365.

.PARAMETER Exclude
Array of user principal names to exclude when using -All parameter.

.PARAMETER UserPrincipalNames
Array of specific user principal names to target for actions.

.EXAMPLES
# Force sign-out a single user
.\Force_Signout_Users_365.ps1 -UserPrincipalNames "Amanda.Morgan@exoip.com" -SignOut

# Block a single user from signing in
.\Force_Signout_Users_365.ps1 -UserPrincipalNames "Amanda.Morgan@exoip.com" -BlockSignIn

# Block a single user from signing in and reset password
.\Force_Signout_Users_365.ps1 -UserPrincipalNames "Amanda.Morgan@exoip.com" -BlockSignIn -ResetPassword

# Block a single user, reset password, and disable registered devices
.\Force_Signout_Users_365.ps1 -UserPrincipalNames "Amanda.Morgan@exoip.com" -BlockSignIn -ResetPassword -DisableDevices

# Force sign-out multiple users
.\Force_Signout_Users_365.ps1 -UserPrincipalNames "Amanda.Morgan@exoip.com","Jonathan.Fisher@exoip.com" -SignOut

# Reset password and disable devices for multiple users
.\Force_Signout_Users_365.ps1 -UserPrincipalNames "Amanda.Morgan@exoip.com","Jonathan.Fisher@exoip.com" -ResetPassword -DisableDevices

# Force sign-out all users
.\Force_Signout_Users_365.ps1 -All -SignOut

# Block sign-in and reset password for all users
.\Force_Signout_Users_365.ps1 -All -BlockSignIn -ResetPassword

# Block sign-in, reset password, and exclude certain users
.\Force_Signout_Users_365.ps1 -All -BlockSignIn -ResetPassword -Exclude "admin@exoip.com","John.Walt@exoip.com"
#>

param (
    [switch]$All,
    [switch]$ResetPassword,
    [switch]$DisableDevices,
    [switch]$SignOut,
    [switch]$BlockSignIn,
    [string[]]$Exclude,
    [string[]]$UserPrincipalNames
)
# Check if no switches or parameters are provided
if (-not $All -and -not $ResetPassword -and -not $DisableDevices -and -not $SignOut -and -not $BlockSignIn -and -not $Exclude -and -not $UserPrincipalNames) {
    Write-Host "No switches or parameters provided. Please specify the desired action using switches such as -All, -ResetPassword, -DisableDevices, -SignOut, -BlockSignIn, or provide user principal names using -UserPrincipalNames." -ForegroundColor Yellow
    Exit
}
# Connect to Microsoft Graph API
Connect-MgGraph -Scopes Directory.AccessAsUser.All
# Retrieve all users if -All parameter is specified
if ($All) {
    $Users = Get-MgUser -All
}
else {
    # Filter users based on provided user principal names
    if ($UserPrincipalNames) {
        $Users = $UserPrincipalNames | Foreach-Object { Get-MgUser -Filter "UserPrincipalName eq '$($_)'" }
    }
    else {
        $Users = @()
        Write-Host "No -UserPrincipalNames or -All parameter provided." -ForegroundColor Yellow
    }
}
# Prompt for the new password if -ResetPassword parameter is specified and there are users to process
$NewPassword = ""
if ($ResetPassword -and $Users.Count -gt 0) {
    $NewPassword = Read-Host "Enter the new password"
}
# Check if any excluded users were not found
$ExcludedNotFound = $Exclude | Where-Object { $Users.UserPrincipalName -notcontains $_ }
foreach ($excludedUser in $ExcludedNotFound) {
    Write-Host "Can't find Azure AD account for user $excludedUser" -ForegroundColor Red
}
# Check if any provided users were not found
$UsersNotFound = $UserPrincipalNames | Where-Object { $Users.UserPrincipalName -notcontains $_ }
foreach ($userNotFound in $UsersNotFound) {
    Write-Host "Can't find Azure AD account for user $userNotFound" -ForegroundColor Red
}
foreach ($User in $Users) {
    # Check if the user should be excluded
    if ($Exclude -contains $User.UserPrincipalName) {
        Write-Host "Skipping user $($User.UserPrincipalName)" -ForegroundColor Cyan
        continue
    }
    
    # Flag to indicate if any actions were performed for the user
    $processed = $false  
# Revoke access if -SignOut parameter is specified
    if ($SignOut) {
        Write-Host "Sign-out completed for account $($User.DisplayName)" -ForegroundColor Green
# Revoke all signed in sessions and refresh tokens for the account
        $SignOutStatus = Revoke-MgUserSignInSession -UserId $User.Id
$processed = $true
    }
# Block sign-in if -BlockSignIn parameter is specified
    if ($BlockSignIn) {
        Write-Host "Block sign-in completed for account $($User.DisplayName)" -ForegroundColor Green
# Block sign-in
        Update-MgUser -UserId $User.Id -AccountEnabled:$False
$processed = $true
    }
# Reset the password if -ResetPassword parameter is specified
    if ($ResetPassword -and $NewPassword) {
        $NewPasswordProfile = @{
            "Password"                      = $NewPassword
            "ForceChangePasswordNextSignIn" = $true
        }
        Update-MgUser -UserId $User.Id -PasswordProfile $NewPasswordProfile
        Write-Host "Password reset completed for $($User.DisplayName)" -ForegroundColor Green
$processed = $true
    }
# Disable registered devices if -DisableDevices parameter is specified
    if ($DisableDevices) {
        Write-Host "Disable registered devices completed for $($User.DisplayName)" -ForegroundColor Green
        
        # Retrieve registered devices
        $UserDevices = Get-MgUserRegisteredDevice -UserId $User.Id
# Disable registered devices
        if ($UserDevices) {
            foreach ($Device in $UserDevices) {
                Update-MgDevice -DeviceId $Device.Id -AccountEnabled $false
            }
        }
$processed = $true
    }
if (-not $processed) {
        Write-Host "No actions selected for account $($User.DisplayName)" -ForegroundColor Yellow
    }
}
