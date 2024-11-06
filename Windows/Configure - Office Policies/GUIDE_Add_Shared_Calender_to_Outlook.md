# Guide: Adding Shared Calendars to Outlook via ADMX in Intune

This guide outlines the steps to configure Microsoft Outlook to automatically add shared calendars using ADMX policies imported into Microsoft Intune. Shared calendars are essential for collaboration in many enterprise environments, and this method ensures they are deployed consistently across users.

## Prerequisites

- **Outlook ADMX Templates**: Ensure the Outlook ADMX templates are imported into Intune. These can be obtained from the [Microsoft Download Center](https://www.microsoft.com/en-us/download/details.aspx?id=49030).
- **Access to Intune**: You need Global Administrator or Intune Administrator rights in the [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com).

---

## Step 1: Download and Import Outlook ADMX Templates

1. Download the latest Outlook ADMX templates from the [Microsoft Download Center](https://www.microsoft.com/en-us/download/details.aspx?id=49030).
2. Extract the `.admx` and `.adml` files to your local machine.
3. Log in to the [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com).
4. Go to **Devices** > **Configuration Profiles** > **+ Create Profile**.
5. Select **Windows 10 and later** as the platform and choose **Administrative Templates**.
6. Click **Import ADMX Files**, then upload the extracted Outlook `.admx` and `.adml` files.
7. Wait for the files to upload, and ensure they appear in the list of available templates.

---

## Step 2: Create a New Policy for Shared Calendars

1. In the Intune portal, go to **Devices** > **Configuration Profiles**.
2. Click **+ Create profile**, and select the following options:
   - **Platform**: Windows 10 and later
   - **Profile type**: Templates > Administrative Templates
3. Under **Configuration settings**, use the search bar to find "Shared Calendars" or navigate manually to: **User Configuration** > **Administrative Templates** > **Microsoft Outlook 2016** > **Account Settings** > **Exchange** > **Shared Calendars*
4. Configure the following settings:

- **Automate Adding Shared Calendars**: Set this to **Enabled**.
- **Specify the List of Shared Calendars**: Enter the SMTP addresses of the shared calendars that should automatically appear in users' Outlook.

  Example:
  ```
  shared.calendar1@yourdomain.com
  shared.calendar2@yourdomain.com
  ```
  This will ensure that these calendars are automatically added to Outlook for all users the policy is applied to.

---

## Step 3: Assign the Policy to Users or Devices

1. Once the policy is created, click **Next**.
2. Under **Assignments**, choose whether to assign the policy to specific user groups or device groups.
- You can create a dynamic user group in Azure Active Directory for the employees who need access to these shared calendars.
3. Click **Next** to review the settings, then click **Create** to deploy the policy.

---

## Step 4: Verify Policy Deployment

1. To monitor the policy, go to **Devices** > **Monitor** > **Configuration Profiles**.
2. Select the policy you created and verify the deployment status. The policy should be applied to the targeted users or devices.
3. After deployment, users should see the specified shared calendars automatically appear in their Outlook calendar pane without any manual configuration.

---

## Additional Settings (Optional)

### Manage Calendar Permissions

You can also manage shared calendar permissions via ADMX policies if you want to restrict or allow specific types of access to shared calendars. To do this:

1. Navigate to: **User Configuration** > **Administrative Templates** > **Microsoft Outlook 2016** > **Account Settings** > **Permissions**

2. Configure specific permissions such as **Editor**, **Reviewer**, or **Owner** for users accessing shared calendars.

### Disable Calendar Deletion

If you want to prevent users from removing shared calendars from Outlook, you can also configure this setting:

1. Navigate to: User Configuration > Administrative Templates > Microsoft Outlook 2016 > Account Settings > Shared Calendars
2. Enable the **Prevent Deletion of Shared Calendars** setting to lock the shared calendar in place.

---

## Troubleshooting

If the shared calendars do not appear in Outlook:

- **Check Intune Status**: Ensure the policy has been successfully applied to the targeted users/devices.
- **SMTP Accuracy**: Verify that the SMTP addresses of the shared calendars are correct and that users have the appropriate permissions.
- **Client Sync**: Ensure that Outlook is correctly syncing with the Exchange server. You may need to prompt users to restart Outlook or force a sync.

---

## Conclusion

By following these steps, you can automate the process of adding shared calendars to Outlook using ADMX templates in Intune. This ensures a consistent and easy experience for users while maintaining control over how shared calendars are deployed across the organization.
