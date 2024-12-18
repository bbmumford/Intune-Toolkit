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

### Enable & Rename the Built-in Administrator Account via Settings Catalog

Enable the default built-in Administrator account on Windows 10/11 devices using the following steps:

**Note**: This method can fail in the order of events & is best deployed injunction with the remediation script.
```
   |-Script
   |---Configure-LocalAdministrator
```

1. Log in to the **Intune admin center**.
2. Navigate to **Devices > Configuration profiles > Create > New Policy**.
3. Select **Platform** as **Windows 10 and later**.
4. Choose **Profile type** as **Settings Catalog**.
5. Provide a **Name** and **Description** for the profile. Click **Next**.
    - Name the policy something clear such as **Configure-LocalAdministratorAccount**
6. In **Configuration settings**, click **Add settings**, search for **Local Policies Security Options**, select **Accounts Enable Administrator Account** & select **Accounts: Rename Administrator Account**.
7. Toggle the setting to **Enable** & set the desired name.
8. Save the profile and assign it to the desired devices or device groups.

### ALTERNATIVELY Renaming the Built-in Administrator Account via Template Endpoint protection 

To rename the built-in Administrator account:

1. Log in to the **Intune admin center**.
2. Navigate to **Devices > Configuration profiles > Create > New Policy**.
3. Select **Platform** as **Windows 10 and later**.
4. Choose **Profile type** as **Templates**.
3. Select **Endpoint Protection**
5. Provide a **Name** and **Description** for the profile. Click **Next**.
    - Name the policy something clear such as **AdministratorAccount-Rename**
6. In **Configuration settings**, click **Local device security options**.
7. Under "Admin", in the **Rename admin account** field, enter the desired name.
8. Save the profile and assign it to the desired devices or device groups.

---

## Part 3: Configuring Intune Device User Local Administrator Privileges via Endpoint Security

### 1. Navigate to Endpoint Security:
- Open the **Microsoft Endpoint Manager Admin Center**: [https://endpoint.microsoft.com](https://endpoint.microsoft.com).
- Go to **Endpoint Security** > **Account protection**.

### 2. Create an Account Protection Policy:
- Select **+ Create Policy**.
- Choose the platform: **Windows 10 and later**.
- Select the profile type: **Local user group membership**.
- **Recommended Policy Name**: 
  - Use a clear and descriptive naming convention such as:
    - **"AccountProtection-LocalAdmins-AllDevices"**: For global scope.
    - **"AccountProtection-LocalAdmins-US"**: For regional-specific policies.
    - **"AccountProtection-LocalAdmins-ITSupport"**: For IT Support administrator groups.

### 3. Configure Local Administrator Membership:
- In the **Local user group membership** settings:
  - Choose **Administrators** for the group.
  - Add the **Device Local Admins** group (associated with the **Microsoft Entra Joined Device Local Administrator** role):
    - Go to the **Azure Portal**: [https://portal.azure.com](https://portal.azure.com).
    - Navigate to **Azure Active Directory** > **Roles and administrators**.
    - Locate the & add the **Device Local Admins** group.
      - This group is associated to the **Microsoft Entra Joined Device Local Administrator** role.
    - Alternatively assign users or additional groups (e.g., IT Support, regional admins) to the **Device Local Admins** group for centralized management.

### 4. Best Practice Naming Conventions for Groups:
To maintain clarity and scalability, use structured and descriptive names for groups:

#### Global Scope:
- **Global-Device-Admins**: For users who need administrative access to all devices across the organization.
- **Global-IT-Admins**: Broader administrative role encompassing devices, Intune policies, and configurations.

#### Regional Scope:
- **Device-Admins-US**: Local admin access for devices in the US region.
- **Device-Admins-EU**: For administrative roles tied to Europe-based devices.

#### Role-Specific or Functional Teams:
- **Device-Local-Admins** (default): Used for the **Microsoft Entra Joined Device Local Administrator** role.
- **Helpdesk-Admins-Tier1**: For IT Help Desk or Tier 1 support staff who may require temporary elevated access.
- **Device-Support-Admins**: Specific groups for IT or support teams managing devices in specific areas or departments.

### 5. Assign the Policy:
- Under **Assignments**, target the policy to **device groups** or **user groups**:
  - Example: Assign to dynamic groups like:
    - `Intune_Devices_All`: All devices under management.
    - `Intune_Devices_Enrolled`: Devices that have completed enrollment.
    - `Intune_Devices_{OrderID}`: Devices based on project or department requirements.

### 6. Monitor Policy Deployment:
- Go to **Endpoint Security** > **Account protection** to view the policy deployment status.

### Why Naming Conventions Matter:
- **Clarity**: Simplifies understanding of group purpose and scope.
- **Scalability**: Enables seamless addition of new groups or changes in scope (e.g., by region or department).
- **Automation**: Integrates well with dynamic group rules for Intune or Azure AD.

#### Example Scenarios:
- Assigning **Device-Local-Admins** ensures users are automatically added to the correct local administrator group during device enrollment.
- Using **Intune_Devices_Prepare** or **Intune_Devices_Enrolled** for assignments ensures consistent targeting of devices.
- Naming the policy **"AccountProtection-LocalAdmins-AllDevices"** makes it immediately clear what the policy does and its target scope.

### Summary of Recommendations:
- **Policy Name**: "AccountProtection-LocalAdmins-{Scope}"
  - Replace `{Scope}` with "AllDevices," "US," "EU," or other regions or teams as needed.
- **Group Naming**: Use structured names like `Global-Device-Admins`, `Device-Admins-US`, or `Helpdesk-Admins-Tier1`.

---

By following these steps, you can securely configure local admin accounts and manage them effectively using Intune.