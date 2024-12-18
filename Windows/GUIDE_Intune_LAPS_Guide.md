# Enabling Intune Local Administrator Password Solution (LAPS)

This guide provides step-by-step instructions on how to enable and configure Intune Local Administrator Password Solution (LAPS) to manage local administrator passwords on Windows devices.

## Overview
Microsoft Local Administrator Password Solution (LAPS) integrates with Azure AD and Intune to automatically manage local administrator passwords on Windows devices. This ensures security through unique, regularly rotated passwords.

---

## Prerequisites
- **Supported OS:** Windows 10 (Pro/Education/Enterprise) version 20H2 or later, Windows 11.
- **Azure AD Join** or **Hybrid Azure AD Join**.
- **Microsoft Intune License** assigned to devices/users.
- Ensure devices are enrolled in Intune and managed with AccountProtection policies enabled.

---

## Step 1: Enable LAPS in Azure AD
1. **Sign in** to the [Microsoft Entra Admin Center](https://entra.microsoft.com/).
2. Navigate to `Devices > Device Settings`.
3. Locate the **Local Administrator Password Solution (LAPS)** section.
4. Set **Enable Azure AD LAPS** to `Yes`.
5. Click **Save**.

---

## Step 2: Configure AccountProtection Policy in Intune
1. **Log in** to the [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
2. Go to `Devices > Configuration profiles`.
3. Click **+ Create profile**:
   - **Platform:** Windows 10 and later.
   - **Profile Type:** Templates > Account protection.
4. **Configure Policy Settings:**
   - **Policy Name:** `AccountProtection-LAPS` or something else structured.
   - **Description:** "Enables LAPS for Azure AD Joined/Hybrid Azure AD Joined devices."

### Account Protection Settings
- **Backup directory:** Set to `Azure AD`.
- Enable **Password Age Days**
- **Password Age Days:** `16`.
- Enable **Account Administrator Name**
- Set the name of the local admin account you will be using.
   - You may want to enable the device local default Aministrator or create a new local admin user to provide the usename of. In that case [the following guide](/Windows/Configure%20-%20%20Local%20Admin/Create_Local_Administrator.md)
- **Password complexity:** `Default`.
- Enable **Password Length** by deafult when not enabled it is 14.
- **Password length:** `16` this mimimum is 8 & maximum 12.
- **Post-authentication actions:** `Reste passeword: upon expiry of grace period, the managed account password will be reset`
- Enable **Post Authentication Reset Delay**
- **Post Authentication Reset Delay:** `1`

5. Click **Next**.
6. **Assignments:**
   - Assign to a dynamic or static group containing target devices.
   - Example Dynamic Group Query:
     ```plaintext
     (device.deviceOSType -eq "Windows")
     ```
7. **Review and Create:** Confirm settings and create the policy.

---

## Step 3: Verify LAPS Deployment
1. Navigate to `Devices > All Devices` in the Intune Admin Center.
2. Select a device and go to `Device Configuration > Policies`.
3. Check the compliance status of the **AccountProtection-LAPS** policy.

---

## Step 4: Retrieve Local Administrator Passwords
1. **Access Azure AD:**
   - Go to `Devices > All Devices` in the Entra Admin Center.
   - Select the target device.
   - Click **Device Passwords** to retrieve the current local admin password.

2. **Via PowerShell:**
   - Use the `Get-LapsAADPassword` cmdlet from the LAPS PowerShell module:
     ```powershell
     Get-LapsAADPassword -DeviceName "DeviceName"
     ```

---

## Best Practices
- **Restrict access** to the Device Passwords pane in Azure AD using Role-Based Access Control (RBAC).
- Regularly review and audit access logs for password retrieval.
- Use conditional access policies to secure admin accounts.

---

## Troubleshooting
- Ensure devices have the latest Windows updates to support LAPS.
- Verify that the `AccountProtection-LAPS` policy is assigned and applied successfully.
- Check for errors in `Event Viewer > Applications and Services Logs > Microsoft > Windows > LAPS` on target devices.

1. **Policy Not Applying**
   - Ensure that the device is properly enrolled in Intune and that the LAPS policy is assigned to the correct device group.
   - Check the device’s sync status and force a policy sync if necessary.

2. **Password Retrieval Issues**
   - Verify that the device has successfully received the LAPS policy and that the password is being stored correctly.
   - Check for any errors or warnings in the `Event Viewer` related to LAPS.

---

For further assistance, refer to the [Microsoft Documentation on LAPS](https://learn.microsoft.com/en-us/windows-server/identity/laps/).
SS