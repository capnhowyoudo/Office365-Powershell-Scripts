<#
.SYNOPSIS
    Creates a Microsoft 365 (Unified) Group with dynamic membership
    for all enabled, licensed users.

.DESCRIPTION
    Connects to Microsoft Graph and creates a Microsoft 365 group whose
    membership is dynamically maintained based on a membership rule.
    The rule includes any user who is enabled (accountEnabled = true)
    and has at least one licensed (Enabled) service plan assigned —
    regardless of domain.

    The script sanitizes the provided MailNickname and verifies it is
    not already in use before attempting to create the group.

.EXAMPLE
    .\Create_Dynamic_Group_Licensed_Users.ps1

    Creates a group using all default parameter values (name, nickname,
    and description as defined in the param block).

.EXAMPLE
    .\Create_Dynamic_Group_Licensed_Users.ps1 -GroupName "All Licensed Users" -MailNickname "AllLicensedUsers"

    Creates a Microsoft 365 group named "All Licensed Users" with a
    dynamic membership rule matching every enabled, licensed user in
    the tenant.

.NOTES
    Requires the Microsoft.Graph PowerShell module:
        Install-Module Microsoft.Graph -Scope CurrentUser

    Dynamic membership requires an Azure AD P1/P2 license on the tenant.

    MailNickname restrictions:
        Mail nicknames can't contain spaces or these characters:
        @ ( ) \ [ ] " ; : <> , SPACE
        The script auto-strips invalid characters, but it's best to pass
        a clean value (letters, numbers, '.', '_' or '-' only).
#>

param(
    [string]$GroupName    = "All Licensed Users",
    [string]$MailNickname = "AllLicensedUsers",
    [string]$Description  = "Dynamic Microsoft 365 group of all enabled, licensed users"
)

# 1. Connect to Microsoft Graph with the scopes needed to manage groups
Connect-MgGraph -Scopes "Group.ReadWrite.All","Directory.ReadWrite.All"

# 2. Sanitize the mail nickname (no spaces or special characters allowed)
$MailNickname = $MailNickname -replace '[^a-zA-Z0-9._-]', ''
if ([string]::IsNullOrWhiteSpace($MailNickname)) {
    throw "MailNickname is empty after sanitization. Provide a value using only letters, numbers, '.', '_' or '-'."
}

# Check the nickname isn't already taken by another group
$existing = Get-MgGroup -Filter "mailNickname eq '$MailNickname'" -ErrorAction SilentlyContinue
if ($existing) {
    throw "A group with MailNickname '$MailNickname' already exists (Id: $($existing.Id)). Choose a different -MailNickname."
}

# 3. Dynamic membership rule: enabled + licensed users, any domain
$membershipRule = '(user.accountEnabled -eq true) and (user.assignedPlans -any (assignedPlan.servicePlanId -ne "" -and assignedPlan.capabilityStatus -eq "Enabled"))'

# 4. Create the Microsoft 365 group with dynamic membership enabled
$params = @{
    DisplayName                   = $GroupName
    MailNickname                  = $MailNickname
    Description                   = $Description
    MailEnabled                   = $true
    SecurityEnabled                = $false   # M365 groups are typically SecurityEnabled = $false
    GroupTypes                    = @("Unified", "DynamicMembership")
    MembershipRule                = $membershipRule
    MembershipRuleProcessingState = "On"
}

$group = New-MgGroup @params

Write-Host "Created group '$($group.DisplayName)' with Id: $($group.Id)"
Write-Host "Membership rule:`n$membershipRule"
