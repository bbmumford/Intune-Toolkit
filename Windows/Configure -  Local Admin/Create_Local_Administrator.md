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