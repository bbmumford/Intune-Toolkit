# Configuring Intune Policies to Add Extensions to Chrome & Edge

## Prerequisites
- An active Microsoft Intune subscription
- Administrator access to the Intune portal

## Steps to Add Extensions to Google Chrome

1. **Log into Intune:**
   - Navigate to the [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com).

2. **Create a new configuration profile:**
   - In the left-hand menu, select **Devices**.
   - Choose **Configuration profiles**.
   - Click on **Create profile**.

3. **Select platform and profile type:**
   - Under **Platform**, select **Windows 10 and later**.
   - For **Profile**, choose **Templates** and then select **Administrative Templates**.

4. **Configure the Chrome extension settings:**
   - In the **Configuration settings** tab, search for **Google Chrome**.
   - Expand the **Google Chrome** section.
   - Locate and configure the following settings:
     - **Configure the list of force-installed apps and extensions**
       - Set this to **Enabled**.
       - Add the extension IDs in the format: `extension_id;https://clients2.google.com/service/update2/crx`.
         - Example: `abcde12345;https://clients2.google.com/service/update2/crx`.

5. **Assign the profile:**
   - Click **Next** until you reach the **Assignments** section.
   - Select the user or device groups to which you want to apply the policy.
   - Click **Next** to proceed.

6. **Review and create:**
   - Review your settings and click **Create** to finalize the configuration.

## Steps to Add Extensions to Microsoft Edge

1. **Log into Intune:**
   - Navigate to the [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com).

2. **Create a new configuration profile:**
   - In the left-hand menu, select **Devices**.
   - Choose **Configuration profiles**.
   - Click on **Create profile**.

3. **Select platform and profile type:**
   - Under **Platform**, select **Windows 10 and later**.
   - For **Profile**, choose **Templates** and then select **Administrative Templates**.

4. **Configure the Edge extension settings:**
   - In the **Configuration settings** tab, search for **Microsoft Edge**.
   - Expand the **Microsoft Edge** section.
   - Locate and configure the following settings:
     - **Control which extensions are installed silently**
       - Set this to **Enabled**.
       - Add the extension IDs in the format: `extension_id;https://microsoftedge.microsoft.com/extensionwebstore/`.

5. **Assign the profile:**
   - Click **Next** until you reach the **Assignments** section.
   - Select the user or device groups to which you want to apply the policy.
   - Click **Next** to proceed.

6. **Review and create:**
   - Review your settings and click **Create** to finalize the configuration.

## Verification
- After deploying the policies, verify that the extensions are installed correctly by launching Chrome and Edge on the assigned devices.

## Additional Notes
- Ensure that the extension IDs and URLs are correct to avoid installation issues.
- Check for any conflicts with existing policies that might affect extension installations.

## Useful Extensions
### Chrome
- [Tab Limiter](https://chromewebstore.google.com/detail/tab-limiter/pbpfchnddjilendkobiabenojlniemoh)
- [Tab Suspender](https://chromewebstore.google.com/detail/auto-tab-discard-suspend/jhnleheckmknfcgijgkadoemagpecfol)
### Edge
- [Tab Suspender](https://microsoftedge.microsoft.com/addons/detail/auto-tab-discard-suspend/nfkkljlcjnkngcmdpcammanncbhkndfe)