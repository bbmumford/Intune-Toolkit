# Guide to Importing HASH Keys into Microsoft Intune

## Overview

Importing HASH keys into Microsoft Intune is essential for managing devices, especially for security policies and compliance. This guide provides step-by-step instructions on how to do this.

## Prerequisites

Before you begin, ensure you have the following:

- **Microsoft Intune Admin Access**: You need to be an administrator in Microsoft Intune.
- **HASH Key File**: Prepare the HASH key file you want to import. This file should be in a compatible format (e.g., CSV).

## Steps to Import HASH Keys

### Step 1: Log in to Microsoft Intune

1. Open a web browser.
2. Go to the [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com).
3. Sign in with your administrator account.

### Step 2: Navigate to Devices

1. In the left-hand menu, click on **Devices**.
2. Select **All devices** to view the list of managed devices.

### Step 3: Access the Device Compliance Policies

1. In the Devices menu, click on **Compliance policies**.
2. Select **Policies** to see existing compliance policies.

### Step 4: Create or Edit a Compliance Policy

1. To create a new policy, click on **Create Policy**.
2. Choose the platform for the policy (e.g., Windows, iOS, Android).
3. Follow the prompts to set up your compliance policy.

### Step 5: Import the HASH Keys

1. Within the compliance policy settings, look for an option that mentions importing HASH keys.
2. Click on **Import** or **Upload**.
3. Browse for the HASH key file you prepared earlier.
4. Select the file and confirm the upload.

### Step 6: Review and Save

1. Once the HASH keys are imported, review the entries to ensure they are correct.
2. Click **Save** to apply the changes to the compliance policy.

### Step 7: Assign the Policy

1. After saving, assign the policy to the necessary user groups or devices.
2. Click on **Assignments** in the policy settings.
3. Select the groups you want to target and confirm the assignment.

## Conclusion

You have successfully imported HASH keys into Microsoft Intune. Make sure to monitor the compliance status of the devices to ensure they meet the specified security requirements.

## Additional Resources

- [Microsoft Intune Documentation](https://docs.microsoft.com/en-us/mem/intune/)
- [Device Compliance Policies in Intune](https://docs.microsoft.com/en-us/mem/intune/protect/compliance-policy-overview)
