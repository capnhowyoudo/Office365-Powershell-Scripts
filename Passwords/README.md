# PowerShell Scripts for Password Management

## Overview

This repository contains PowerShell scripts designed to manage passwords for Office 365 accounts.

# ⚠️ WARNING:
These scripts are **only compatible with Office 365** (Microsoft 365) cloud accounts and **do not work with Active Directory (AD) or AD Connect** environments.

This script is designed to manage passwords for **Office 365 (Microsoft 365) accounts only**.

❌ It **will NOT work** with Active Directory (AD) or AD Connect-managed accounts.
Password changes for AD Connect users must be performed in your on-premises AD environment.

## Details

* The scripts use **Microsoft Graph PowerShell** (including **Beta**) or **Exchange Online PowerShell** (`Connect-ExchangeOnline`) to reset or manage user passwords.
* If your organization uses **AD Connect** to synchronize on-premises Active Directory accounts with Office 365, these scripts will **not work** because password changes must occur in your local AD.
* Attempting to run these scripts against AD Connect-managed users will not update their passwords in the local Active Directory and may cause errors.

## Requirements

* PowerShell 5.1 or later
* Installed modules:

  * `Microsoft.Graph`
  * `Microsoft.Graph.Beta`
  * `ExchangeOnlineManagement`
* Appropriate Office 365 admin permissions

## Usage

1. Connect to Office 365 using the appropriate module:

   ```powershell
   Connect-MgGraph             # Microsoft Graph (v1.0)
   Connect-MgGraph -UseBeta    # Microsoft Graph Beta
   Connect-ExchangeOnline      # Exchange Online
   ```
2. Run the desired password management script according to the instructions in each script.

## Support

For AD Connect environments, please manage passwords through your on-premises Active Directory tools or scripts.
