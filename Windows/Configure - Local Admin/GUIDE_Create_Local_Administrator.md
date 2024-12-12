# Setting Up a Local Admin Account in Intune and Configuring LAPS

This guide outlines the steps to set up a local admin account in Intune and configure the Local Administrator Password Solution (LAPS) for managing the password.

## Part 1: Configuring LAPS in Intune

Follow these steps to enable and configure LAPS:

1. Log in to the Intune portal using your administrator credentials.
2. Navigate to the **Devices** tab and select **Configuration profiles** from the left-hand menu.
3. Click **Create profile** and choose **Windows 10 and later** as the platform.
4. Select **Endpoint protection** as the profile type.
5. Provide a name for the profile and click on **Settings**.
6. Scroll down to the **Local Administrator Password Solution (LAPS)** section and enable it.
7. Configure the desired settings for LAPS, such as:
   - Password complexity requirements
   - Password expiration
8. Save the profile and assign it to the desired devices or device groups.

### Result:
Once assigned, Intune will automatically manage the local admin account's password on targeted devices using LAPS. This ensures the password is regularly rotated and securely stored.

---

## Part 2 (Approach 1): Adding a Local Account in Intune

To add a dedicated local account for administrative purposes, follow these steps:

### Step 1: Create a Custom Configuration Profile
1. Go to **Devices** > **Configuration profiles** > **+ Create profile**.
2. Configure the following:
   - **Platform**: `Windows 10 and later`
   - **Profile type**: `Templates > Custom`
3. Click **Create**.

---

### Step 2: Configure OMA-URI Settings
1. Provide a **Name** (e.g., "Create Local Admin Account").
2. Click **Next** to proceed to the **Configuration settings**.
3. Add the following OMA-URI configurations:

#### **Create the Local Account Password**
- **Name**: `Set Local Admin Password`
- **Description**: `Sets the password for the local admin account.`
- **OMA-URI**: `./Device/Vendor/MSFT/Accounts/Users/<username>/Password`
  - Replace `<username>` with the desired account name (e.g., `LocalAdmin`).
- **Data type**: `String`
- **Value**: `<password>` (e.g., `SecurePassword123!`)

#### **Add the Account to the Administrators Group**
- **Name**: `Add Local Admin to Administrators`
- **Description**: `Adds the local account to the Administrators group.`
- **OMA-URI**: `./Device/Vendor/MSFT/Accounts/Users/<username>/LocalUserGroup`
  - Replace `<username>` with the account name.
- **Data type**: `Integer`
- **Value**: `2`
  - `0`: Standard user
  - `1`: Power user
  - `2`: Administrator

#### **Optional: Configure Account Properties**
- **Account Expiration**:  
  - **OMA-URI**: `./Device/Vendor/MSFT/Accounts/Users/<username>/AccountEnabled`
  - **Data type**: `Boolean`
  - **Value**: `True` (to enable the account; `False` to disable it).

---

### Step 3: Assign the Profile
1. Assign the profile to the desired device groups.
2. Click **Next** and then **Create** to save and deploy the profile.

---

### Result:
Intune will automatically add the local account to targeted devices, providing a dedicated local admin account for administrative tasks.

---

## Part 2 (Approach 2): Enabling and Renaming the Built-in Administrator Account

### Enabling the Built-in Administrator Account

Enable the default built-in Administrator account on Windows 10/11 devices using the following steps:

1. Log in to the **Intune admin center**.
2. Navigate to **Devices > Configuration profiles > Create > New Policy**.
3. Select **Platform** as **Windows 10 and later**.
4. Choose **Profile type** as **Settings Catalog**.
5. In **Configuration settings**, click **Add settings**, search for **Local Policies Security Options**, and select **Accounts: Enable Administrator Account**.
6. Toggle the setting to **Enable**.
7. Save the profile and assign it to the desired devices or device groups.

---

### Renaming the Built-in Administrator Account

To rename the built-in Administrator account:

1. Log in to the **Intune admin center**.
2. Navigate to **Devices > Configuration profiles > Create > New Policy**.
3. Select **Platform** as **Windows 10 and later**.
4. Choose **Profile type** as **Settings Catalog**.
5. Provide a **Name** and **Description** for the profile. Click **Next**.
6. In **Configuration settings**, click **Add settings**.
7. Search for "rename admin" in the **Settings picker**.
8. Under **Local Policies Security Options**, select **Accounts: Rename Administrator Account**.
9. Configure the new name for the Administrator account and save the profile.

### About the Rename Policy:

The **Accounts: Rename Administrator Account** policy changes the default name of the built-in Administrator account. Renaming the account makes it more challenging for unauthorized users to guess the username-password combination.

### Result:
Once the policy is applied, the built-in Administrator account will be renamed, enhancing security.

---

By following these steps, you can securely configure local admin accounts and manage them effectively using Intune.