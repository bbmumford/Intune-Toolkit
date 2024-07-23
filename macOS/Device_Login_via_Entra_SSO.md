# Configuring Entra Platform Single Sign-On (SSO) for macOS

This guide provides step-by-step instructions on how to configure Entra Platform Single Sign-On (SSO) for macOS using Microsoft Intune.

If you are looking to utalise the plugin, see the scripts "Configure Admin System-Wide Prefences", "Manage Accounts" & "M356 Profile Photo Sync" for additional best pratices.

## Prerequisites

Before you start, ensure you have the following:
- Admin access to Microsoft Entra (Azure Active Directory) and Microsoft Intune.
- An Apple Developer account or access to Apple Business Manager if needed.
- macOS devices that are enrolled in Intune.

## Steps

### Step 1: Prepare SSO Configuration in Azure AD

1. **Log in to the Azure Portal**
   - Go to [Azure Portal](https://portal.azure.com/).
   - Sign in with your admin credentials.

2. **Navigate to Azure Active Directory**
   - In the left-hand sidebar, click on `Azure Active Directory`.

3. **Go to Enterprise Applications**
   - Click on `Enterprise applications`.

4. **Select or Add an Application**
   - Choose the application you want to configure for SSO, or click `+ New application` to add a new one.

5. **Configure Single Sign-On**
   - Click on `Single sign-on`.
   - Choose the SSO method (SAML or OAuth) based on the application’s requirements.
   - Complete the configuration by providing required details like SSO URL, Identifier (Entity ID), Reply URL (Assertion Consumer Service URL), and uploading the SSO certificate if needed.

6. **Save Configuration**
   - Save the configuration and note any necessary URLs or credentials.

### Step 2: Configure macOS Devices in Intune

1. **Open Microsoft Endpoint Manager Admin Center**
   - Go to [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
   - Sign in with your admin credentials.

2. **Navigate to Configuration Profiles**
   - In the left-hand sidebar, click on `Devices` > `macOS` > `Configuration profiles`.

3. **Create a New Profile**
   - Click `+ Create profile`.
   - Select `macOS` as the platform.
   - Choose `Custom` for the profile type.

4. **Add SSO Configuration**
   - Enter a name and description for the profile.
   - Click `Add` under `Configuration settings`.
   - Use the following `Payload type` for SSO:
     - **Payload Type**: `com.microsoft.intune`
     - **Configuration Type**: `SSO`
   - Configure the settings with the SSO details from Azure AD:
     - **SSO URL**: The URL provided by Azure AD for SSO.
     - **SSO Certificate**: Upload the SSO certificate if required.

5. **Assign the Profile**
   - Click `Assignments` and select the groups of macOS devices that should receive the SSO profile.
   - Click `Next`, review the settings, and click `Create`.

### Step 3: Enroll macOS Devices

1. **Ensure Devices Are Enrolled**
   - Verify that the macOS devices are enrolled in Intune.
   - If not enrolled, follow the [Intune macOS enrollment guide](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-enroll).

2. **Apply the SSO Profile**
   - Once devices are enrolled, the SSO configuration profile will be applied automatically.

### Step 4: Test and Verify SSO Configuration

1. **Restart macOS Device**
   - Restart the macOS device to apply the new SSO settings.

2. **Test SSO Login**
   - Open a browser and navigate to the SSO-enabled application.
   - Attempt to log in using your Entra credentials.

3. **Verify Login**
   - Ensure the login is successful and that the user is redirected to the application correctly.

### Troubleshooting

1. **SSO Configuration Issues**
   - Verify the SSO URL, certificate, and other configuration settings in both Azure AD and Intune.

2. **Enrollment Issues**
   - Check that the device is properly enrolled and that the configuration profile is applied.

3. **Authentication Errors**
   - Confirm that the user credentials are correct and that the user has the necessary permissions to access the application.

## Conclusion

By following these steps, you have successfully configured Entra Platform Single Sign-On (SSO) for macOS devices using Microsoft Intune. This setup streamlines user authentication and enhances security by leveraging SSO capabilities.

For more detailed information, refer to the official [Microsoft documentation on configuring SSO for macOS](https://learn.microsoft.com/en-us/mem/intune/configuration/platform-sso-macos).

If you are looking to utalise the plugin, see the scripts "Configure Admin System-Wide Prefences", "Manage Accounts" & "M356 Profile Photo Sync" for additional best pratices.