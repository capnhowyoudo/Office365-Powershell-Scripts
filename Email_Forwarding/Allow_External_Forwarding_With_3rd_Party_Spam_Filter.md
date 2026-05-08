# Allowing External Forwarding When A 3rd Party Spam Filter Is Setup

> :information_source: Use this procedure only if you are receiving a “Relay Access Denied” error while your Microsoft 365 environment is integrated with a third-party spam filter (e.g., Proofpoint).

# Before you begin
-	Confirm the tenant routes outbound mail through Proofpoint using an Exchange Online connector.
-	Confirm the NDR or message trace shows relay rejection, such as 554 5.7.1 Relay access denied.
-	Have Exchange Admin Center permissions to create connectors and mail flow rules.
-	Have one external test recipient available for connector validation.
-	Understand the security tradeoff: matching messages will bypass Proofpoint and send directly using MX lookup.


# Create the bypass connector

**Step 1: Open Exchange Admin Center**

  - Go to https://admin.exchange.microsoft.com and sign in with an account that can manage mail flow.

**Step 2: Go to connectors**

  - Select Mail flow, then Connectors.

**Step 3: Create a new connector**

  - Select Add a connector.

**Step 4: Set connector direction**

  - Choose From: Office 365 and To: Partner organization, then select Next.

**Step 5: Name the connector**

  - Name it Bypass Proofpoint. 
  - Add a description such as: Used only by transport rule to route forwarded external-to-external messages directly by MX and bypass Proofpoint.

**Step 6: Use only when a rule redirects to it**

  - Choose Only when I have a transport rule set up that redirects messages to this connector.

**Step 7: Route by MX record**

  - Choose Use the MX record associated with the partner domain.

**Step 8: Keep default security settings**

  - Leave the default TLS/security settings unless your organization requires a specific TLS policy.

**Step 9: Validate the connector**

  - When prompted, test with an external address outside your accepted domains. Complete validation and save the connector.

> :information_source: Do not make this your normal outbound Proofpoint connector. This connector should only be used when a mail flow rule redirects messages to it.

# Create the mail flow rule

**Step 1: Open rules**

  - In Exchange Admin Center, go to Mail flow, then Rules.

**Step 2: Create a new rule**

  - Select Add a rule, then Create a new rule.

**Step 3: Name the rule**

  - Use a clear name such as Bypass Proofpoint for External Forwards.

**Step 4: Add sender condition**

  - For Apply this rule if, choose The sender is located, then select Outside the organization.

**Step 5: Add recipient condition**

  - Add another condition: The recipient is located, then select Outside the organization.

**Step 6: Redirect to connector**

  - For Do the following, choose Redirect the message to, then The following connector, and select Bypass Proofpoint.

**Step 7: Stop additional processing**

  - Enable Stop processing more rules so the message is not re-routed by another outbound connector rule.

**Step 8: Disable audit severity if not needed**

  - Uncheck Audit this rule with severity unless your change-control process requires it.

**Step 9: Save and prioritize**

  - Save the rule, then move it to the top of the mail flow rules list.

<img width="753" height="152" alt="image" src="https://github.com/user-attachments/assets/9d2129bf-07bc-45e0-9639-955f2d891626" />

# Test and verify

1.	Send a test message from an external sender to the mailbox or distribution group that forwards externally.
3.	Confirm the original internal recipient receives the message if applicable.
4.	Confirm the external forwarded recipient receives the message.
5.	Run message trace in Exchange Admin Center and verify the message matched the bypass rule and used the Bypass Proofpoint connector.
6.	Confirm the NDR no longer appears for Relay access denied.

# Caveats and security notes
-	Messages that match this rule will not pass through Proofpoint outbound filtering.
-	Forwarding can break SPF, DKIM, or DMARC alignment for the original sender.
-	Keep the rule as narrow as possible. The generic external-to-external rule is broad; review whether your environment can use narrower conditions such as specific forwarding mailboxes, distribution groups, or a header condition.
-	Document the exception and monitor message trace after deployment.
