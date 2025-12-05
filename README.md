# Office365-Powershell-Scripts

:warning: Use At Your Own Risk — PowerShell Scripts

:heavy_exclamation_mark: I do not take credit for all of the scripts in this repository. Some scripts were created by others and may have been slightly modified—or not modified at all. Any script that was not originally written by me will retain the original author’s name in the notes section.

A collection of PowerShell cmdlets and scripts designed for Office 365 administration.

# Supported PowerShell: 
1. PowerShell 5.1 
2. PowerShell 7+

# Requirements

- ExchangeOnline Module 
- Microsoft.Graph Module
- PowerShell 7+
- Windows PowerShell 5.1
- Admin privileges (only if required by the script actions)


> :information_source: You must first connect with one of the modules listed below before running any cmdlets or scripts. 
> 1. Connect-ExchangeOnline
> 2. Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All" 

# :warning: High-level disclaimer

These PowerShell scripts are provided as-is, without warranty of any kind. By running or using these scripts you accept full responsibility for any consequences — including data loss, system instability, security issues, or legal/regulatory impacts. Do not run these scripts on production systems unless you understand every line and have tested them in a safe environment.

Recommended precautions (must-read)

- Test in a sandbox or VM first (e.g., a disposable virtual machine or container).

- Back up important data before running anything that modifies files, system settings, the registry, or user accounts.

- Review the entire script line-by-line. Do not run blindly.

- Run with least privilege — only elevate to Administrator when absolutely necessary.

- Use -WhatIf / -Confirm switches in cmdlets that support them while testing.

- Use Get-ExecutionPolicy -List to check system policies and avoid changing global policies permanently.

- Prefer signed scripts — consider signing with an Authenticode certificate for production use.

- Use source control (Git) and code review for changes to the script.
