# Configuring High Volume Email for Payment

High Volume Email (HVE) in Exchange Online has been free to use during its two-plus years in preview. Starting **June 1, 2026**, it will cost **$42 per million recipients** (internal delivery only — HVE does not send to external recipients), billed through an Azure subscription.

Here's how to set up billing for it.

## 1. Check the HVE Admin Portal

Go to the Exchange Online admin portal:

> `https://admin.cloud.microsoft/exchange` → **Mail Flow** → **High Volume Email**

You'll see a notice about the new billing policy requirement. If it's past June 1, 2026 and an account has no policy attached, that account will stop working and will show a **"Not active"** status.

- Each HVE account needs its own billing policy.
- Accounts can each have a unique policy, share one policy, or use some mix of the two.
- However, **one HVE account cannot be linked to more than one policy** — you can't split billing for a single account across policies.

If you already have Microsoft 365 pay-as-you-go billing set up and just need to attach it to an existing account, click **Connect a policy** next to the account name. If no policies exist yet, the "Select billing policy" dropdown will be empty.

> The **General** tab holds the rest of the HVE settings (covered separately). If there's a problem with the billing policy, it will also show up as an error state on this tab.

## 2. Set Up Pay-As-You-Go Billing

Before assigning a policy, make sure Microsoft 365 pay-as-you-go billing is enabled for your tenant:

> `https://admin.cloud.microsoft/` → **Billing** → **Pay-as-you-go**

From here, create (or update) a billing policy.

### Step 1 — Name and Azure details
Give the policy a clear name and provide the three required Azure values:
- Azure subscription
- Resource group
- Region

You can reuse an existing subscription/resource group, or create new ones and pick whatever region works best.

> **Tip:** Since this ties into Microsoft 365 billing, use a descriptive name — whoever manages the invoice may not recognize "HVE," so including "email" in the name helps clarify what's being billed.

You *can* assign multiple services to one billing policy, but that makes it harder to trace spend later — a separate policy per service is generally the better approach.

Finish this step by accepting the pay-as-you-go terms and clicking **Next**.

### Step 2 — Choose users
Select who can use this billing profile. Make sure the group you choose includes the Exchange Administrator who is configuring the policy. They don't need to be the person actually paying the bill — that's controlled separately through the Azure subscription settings. This step just determines who can *use* the policy.

### Step 3 — Set a budget
HVE costs **$0.000042 per recipient**, so it's unlikely you'll hit a budget cap — but it's good practice to set one anyway in case of runaway code or an out-of-control automation/agent.

Example configuration:
- **Monthly budget:** £5
- **Alerts:** sent to IT Support at 50%, 75%, and 100% of budget

You can also configure who gets notified and which day the budget resets.

### Step 4 — Review and create
The final page summarizes everything you've configured. Review it and click **Create** to finish setting up the policy.

## 3. Connect the Policy to HVE

Creating the policy isn't enough on its own — you need to connect it to the High Volume Email service, or it won't appear as an option in the Exchange Admin Center.

From the billing policy page, choose **Connect your services…**

> Along with HVE, you'll also see other pay-as-you-go eligible services listed here, such as **Microsoft 365 Copilot** and **Microsoft 365 Backup**.

Save your changes, then return to the Exchange Online Admin Center.

## 4. Attach the Policy in Exchange Admin Center

1. Click **Refresh** on the High Volume Email admin page to load the newly connected policy.
2. Click **Connect a policy**.
3. Select the correct policy from the list.
4. Click **Update** to apply it.

That's it — the account is now billed under the connected policy.

## Creating a New HVE Account

If you're setting up an HVE account from scratch rather than updating an existing one, you'll be prompted to select a pay-as-you-go billing policy as part of the account creation process itself.
