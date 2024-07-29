## Setting up a Local Admin Account in Intune and Configuring LAPS

To set up a local admin account in Intune and configure LAPS (Local Administrator Password Solution) for managing the password, follow these steps:

1. Log in to the Intune portal using your administrator credentials.
2. Navigate to the "Devices" tab and select "Configuration profiles" from the left-hand menu.
3. Click on "Create profile" and choose "Windows 10 and later" as the platform.
4. Select "Endpoint protection" as the profile type.
5. Provide a name for the profile and click on "Settings".
6. Scroll down to the "Local Administrator Password Solution (LAPS)" section and enable it.
7. Configure the desired settings for LAPS, such as password complexity requirements and password expiration.
8. Save the profile and assign it to the desired devices or device groups.

Once the profile is assigned, Intune will automatically manage the password of the local admin account on the targeted devices using LAPS. This ensures that the local admin password is regularly rotated and securely stored.

To add a local account to devices in Intune, follow these steps:

1. Log in to the Intune portal using your administrator credentials.
2. Navigate to the "Devices" tab and select "Configuration profiles" from the left-hand menu.
3. Click on "Create profile" and choose "Windows 10 and later" as the platform.
4. Select "Endpoint protection" as the profile type.
5. Provide a name for the profile and click on "Settings".
6. Scroll down to the "Accounts" section and click on "Add".
7. Choose "Local account" as the account type.
8. Enter the desired username and password for the local account.
9. Optionally, you can specify additional account settings such as account type (administrator or standard user) and account expiration.
10. Save the profile and assign it to the desired devices or device groups.

Once the profile is assigned, Intune will automatically add the local account to the targeted devices. This allows you to have a dedicated local account for administrative purposes on those devices.


# ALTERNATIVLY: Enable & Rename the local default administartor account.

Enable built-in Administrator account using Intune
Enable a built-in Administrator account on Windows 10/11 devices using Intune by creating a Device configuration profile.

1. Sign in to the Intune admin center.
2. Go to Devices > Configuration > Create > New Policy.
3. Enable built-in Administrator account using Intune
4. Enable built-in Administrator account using Intune
5. Select Platform as Windows 10 and later
6. Profile type as Settings Catalog

8. Configuration settings
Click on the Add settings link, search for Local Policies Security Options, and Check the Accounts Enable Administrator Account status policy setting. Then, toggle the switch to Enable.


Rename Built-in Administrator Account using Intune Policy
To rename the built-in Local administrator account using Intune, follow below steps:

1. Sign in to the Intune admin center.
2. Go to Devices > Configuration > Policies tab > Create > New Policy.
3. Rename Built-in Administrator Account using Intune Policy
4. Rename Built-in Administrator Account using Intune Policy
5. Select Platform as Windows 10 and later
6. Profile type as Settings Catalog
7. Enter the Name and Description of the profile. Click on Next to proceed.

8. Configuration Settings
Click on “+ Add settings“
In the Settings picker, search for “rename admin“
Under the Category Local Policy Security Options, Select “Accounts Rename Administrator Account“. Exit out of the Settings picker.
Accounts: Rename administrator account This security setting determines whether a different account name is associated with the security identifier (SID) for the account Administrator. Renaming the well-known Administrator account makes it slightly more difficult for unauthorized persons to guess this privileged user name and password combination. Default: Administrator.

About “Accounts Rename Administrator Account” Policy setting
Rename Built-in Administrator Account using Intune Policy

You can rename the built-in local administrator account using the ‘Accounts Rename Administrator Account’ setting‘. 
Once the Intune policy is successfully applied, the built-in administrator account will be renamed.