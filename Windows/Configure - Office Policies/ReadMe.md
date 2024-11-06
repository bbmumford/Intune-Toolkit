# Guide: Importing Office ADMX into Intune and Configuring Standard Enterprise Policies

This guide will walk you through importing Office ADMX templates into Microsoft Intune and configuring standard enterprise policies.

## Prerequisites

- **Office ADMX Files**: Download the latest Office ADMX templates from the [Microsoft Download Center](https://www.microsoft.com/en-us/download/details.aspx?id=49030).
- **Access to Microsoft Intune**: You need to have access to the Intune portal as a Global Administrator or Intune Administrator.

---

## Step 1: Download and Extract Office ADMX Templates

1. Go to the [Microsoft Download Center](https://www.microsoft.com/en-us/download/details.aspx?id=49030) and download the ADMX files for Office.
2. Extract the ADMX files to a folder on your local machine. The extracted folder should contain `.admx` and `.adml` files.

---

## Step 2: Upload ADMX Files to Intune

1. Log in to the [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com).
2. Navigate to **Devices** > **Configuration Profiles** > **+ Create profile**.
3. Select **Windows 10 and later** for the platform and choose **Administrative Templates (Preview)**.
4. Under **Profile**:
    - Enter a name for the profile (e.g., "Office ADMX Settings").
    - Upload the `.admx` file from the extracted folder by selecting **Import ADMX files**.
5. Upload both the `.admx` and any corresponding `.adml` language files if required.
6. After the upload completes, Intune will parse the ADMX files and allow you to configure policies based on these templates.

---

## Step 3: Configure Standard Enterprise Policies

Now that the ADMX templates are imported, you can configure policies based on them. Below are some standard enterprise policies you may want to apply.

### 1. Disable Macros in Office Documents
- Navigate to **Devices** > **Configuration Profiles**.
- Select your profile or create a new one using the Office ADMX templates.
- Search for the policy to **Disable Macros** under **Office Excel > Security > Trust Center**.
- Set the option to disable all macros without notification.

### 2. Set Auto-Update for Office Apps
- Search for **Office Updates** under **Office > Updates**.
- Set the **Enable Automatic Updates** policy to ensure all Office apps receive updates automatically.

### 3. Configure Privacy Settings
- Search for **Privacy Settings** under **Office > Common > Privacy**.
- Configure options like **Disable sending data to Microsoft** or **Disable Customer Experience Improvement Program (CEIP)**.

### 4. Block Access to Untrusted Files
- Search for **Protected View** under **Office > Security > Trust Center**.
- Configure the setting to **Enable Protected View for files originating from the Internet** to block untrusted files.

### 5. Prevent Office Add-ins
- Search for **Office Add-ins** under **Office > Security**.
- Disable the use of third-party add-ins by setting **Disable all non-Microsoft add-ins**.

---

## Step 4: Assign Policies to Users or Devices

1. After configuring your desired policies, click **Next**.
2. In the **Assignments** section, assign the policy to a group of users or devices in your organization.
3. Review your settings, and click **Create** to deploy the policy.

---

## Step 5: Monitor and Confirm Policy Deployment

1. After deployment, navigate to **Devices** > **Monitor** > **Configuration Profiles**.
2. Select the policy you created to view its deployment status and ensure it is applied successfully.

---

## Best Practices

- **Test Policies**: Before rolling out to the entire organization, create a test group and apply the policies to ensure they work as intended.
- **Review Updates**: Regularly check for updates to Office ADMX templates and import them into Intune to ensure your policies reflect the latest capabilities.
- **Monitor Compliance**: Use the **Compliance** section in Intune to ensure that all devices comply with the policies you’ve configured.

---

By following these steps, you can successfully import Office ADMX templates into Intune and configure standard enterprise policies for your organization.


# Additional Deployments
- [Add Shared/Resource Calender to Outlook](GUIDE_Add_Shared_Calender_to_Outlook.md)