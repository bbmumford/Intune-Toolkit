# Enabling Intune Local Administrator Password Solution (LAPS)

This guide provides step-by-step instructions on how to enable and configure Intune Local Administrator Password Solution (LAPS) to manage local administrator passwords on Windows devices.

## Prerequisites

Before you start, ensure you have the following:
- Admin access to Microsoft Intune and Azure Active Directory.
- Windows 10 or later devices enrolled in Intune.
- Access to the Microsoft Endpoint Manager admin center.

## Steps

### Step 1: Enable LAPS in Microsoft Intune

1. **Log in to Microsoft Endpoint Manager Admin Center**
   - Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
   - Sign in with your admin credentials.

2. **Navigate to Endpoint Security**
   - In the left-hand sidebar, click on `Endpoint security`.

3. **Go to Local Administrator Password Solution (LAPS)**
   - Click on `Local Administrator Password Solution (LAPS)` under the `Account protection` section.

4. **Create a New Policy**
   - Click `+ Create policy`.
   - Choose `Windows 10 and later` as the platform.
   - Select `LAPS` as the profile type.
   - Click `Create`.

5. **Configure LAPS Settings**
   - **Profile Name**: Enter a name for the policy (e.g., `LAPS Configuration`).
   - **Password Settings**:
     - **Password Expiry**: Specify the duration after which the password should be changed (e.g., `30 days`).
     - **Password Complexity**: Configure the complexity requirements for the local administrator password (e.g., minimum length, required characters).
   - **Save Settings**: Click `Next` to proceed with the configuration.

6. **Assign the Policy**
   - Click `Assignments`.
   - Select the groups of devices that should receive the LAPS policy.
   - Click `Next`, review the settings, and click `Create` to finalize the policy.

### Step 2: Configure Device Settings for LAPS

1. **Open Microsoft Intune Admin Center**
   - Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).

2. **Navigate to Devices**
   - Click on `Devices` in the left-hand sidebar.

3. **Configure Device Compliance Policies**
   - Select `Compliance policies` > `Policies`.
   - Click `+ Create policy`.
   - Choose `Windows 10 and later` as the platform.
   - Select `Device Health` or `Configuration` based on your requirements and configure settings as needed.
    - You may want to enable the device local default Aministrator or create a new local admin user to provide the usename of. In that case [the following guide](/Windows/Configure%20-%20%20Local%20Admin/Create_Local_Administrator.md).

4. **Apply the LAPS Policy**
   - Ensure that the LAPS policy created in the previous step is applied to the relevant devices.

### Step 3: Monitor and Verify LAPS Configuration

1. **Check Policy Deployment Status**
   - In the Microsoft Endpoint Manager admin center, go to `Devices` > `Monitor` > `Policies`.
   - Verify that the LAPS policy is successfully deployed to the targeted devices.

2. **Verify LAPS Functionality**
   - On a Windows device, open `Event Viewer` and navigate to `Applications and Services Logs` > `Microsoft` > `Windows` > `LAPS`.
   - Check the event logs for LAPS-related entries to confirm that the policy is applied and functioning correctly.

3. **View Local Administrator Password**
   - Open the Microsoft Intune portal and navigate to the `Local Administrator Password Solution (LAPS)` section.
   - Locate the device for which you want to view the local administrator password.
   - Click on the device to view the current local administrator password details.

### Troubleshooting

1. **Policy Not Applying**
   - Ensure that the device is properly enrolled in Intune and that the LAPS policy is assigned to the correct device group.
   - Check the device’s sync status and force a policy sync if necessary.

2. **Password Retrieval Issues**
   - Verify that the device has successfully received the LAPS policy and that the password is being stored correctly.
   - Check for any errors or warnings in the `Event Viewer` related to LAPS.

## Conclusion

By following these steps, you have successfully enabled and configured Intune Local Administrator Password Solution (LAPS) to manage local administrator passwords on Windows devices. This setup enhances security by ensuring that local administrator passwords are rotated regularly and managed centrally.

For more detailed information, refer to the official [Microsoft documentation on Intune LAPS](https://learn.microsoft.com/en-us/mem/intune/protect/laps).

