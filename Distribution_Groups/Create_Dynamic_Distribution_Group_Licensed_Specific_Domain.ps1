<#
.SYNOPSIS
    Creates a Microsoft 365 (Unified) Group with dynamic membership.

.DESCRIPTION
    Connects to Microsoft Graph and creates a Microsoft 365 group whose
    membership is dynamically maintained based on a membership rule.
    By default, the rule includes users who are enabled, have at least
    one licensed (Enabled) service plan, and whose userPrincipalName
    matches the specified domain.

    The script sanitizes the provided MailNickname and verifies it is
    not already in use before attempting to create the group.

.EXAMPLE
    .\Create_Dynamic_Distribution_Group_Licensed_Specific_Domain.ps1

    Creates a group using all default parameter values (name, nickname,
    and domain as defined in the param block).

.EXAMPLE
    .\Create_Dynamic_Distribution_Group_Licensed_Specific_Domain.ps1 -GroupName "Sales Team" -MailNickname "SalesTeam" -Domain "contoso.com"

    Creates a Microsoft 365 group named "Sales Team" with dynamic
    membership rule matching enabled, licensed users whose UPN ends in
    @contoso.com.

.EXAMPLE
    .\Create_Dynamic_Distribution_Group_Licensed_Specific_Domain.ps1 -GroupName "Marketing" -MailNickname "Marketing" -Domain "fabrikam.com" -Description "All licensed Marketing users"

    Creates the group with a custom description in addition to the
    other parameters.

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
    [string]$GroupName        = "My Dynamic M365 Group",
    [string]$MailNickname     = "MyDynamicM365Group",
    [string]$Domain           = "domainname.com",
    [string]$Description      = "Dynamic Microsoft 365 group based on license and UPN domain"
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

# 3. Build the dynamic membership rule
#    (escape the domain so a literal "." isn't treated as a regex wildcard)
$escapedDomain = [regex]::Escape($Domain)

$membershipRule = @"
(user.accountEnabled -eq true) and (user.assignedPlans -any (assignedPlan.servicePlanId -ne "" -and assignedPlan.capabilityStatus -eq "Enabled")) and (user.userPrincipalName -match "^[A-Z0-9._%+-]+@$escapedDomain`$")
"@

# 4. Create the Microsoft 365 group with dynamic membership enabled
$params = @{
    DisplayName          = $GroupName
    MailNickname         = $MailNickname
    Description          = $Description
    MailEnabled          = $true
    SecurityEnabled      = $false          # M365 groups are typically SecurityEnabled = $false
    GroupTypes           = @("Unified", "DynamicMembership")
    MembershipRule       = $membershipRule
    MembershipRuleProcessingState = "On"
}

$group = New-MgGroup @params

Write-Host "Created group '$($group.DisplayName)' with Id: $($group.Id)"
Write-Host "Membership rule:`n$membershipRule"
