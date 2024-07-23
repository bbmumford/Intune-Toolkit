# Windows 11 Taskbar Customization Using Intune MEM

## Steps to Create a Taskbar Customization Policy

1. **Navigate to Configuration Profiles**
   - Go to `Devices` > `Windows` > `Configuration Profiles`.

2. **Select Profile Details**
   - Choose the platform: `Windows 10 and later`.
   - Select `Profile Type` as `Templates`.

3. **Create a Custom Intune Policy**
   - Click on the `Device Restrictions` option.
   - Click `Create` to start creating a new policy.

4. **Enter Policy Details**
   - On the next page, enter the following details:
     - **Name**: `HTMD Windows 11 Taskbar Layout`
     - **Description**: `Custom Taskbar Layout policy for HTMD`

5. **Upload the XML File**
   - Scroll down to find the `Start` section.
   - Select `Start Menu Layout`
   - Upload the XML file created for taskbar customization. Click the folder icon to upload the [`WIN11Taskbar.XML`](/Windows/Configure%20-%20Taskbar/WIN11Taskbar.xml).

6. **Continue to Assignment**
   - Click `Next` to proceed to the assignment page.
   - Select the `Windows 11 Azure AD device group` to apply the policy.

7. **Review and Create**
   - Click `Next` to review the settings.
   - Click `Create` to finalize and deploy the policy.

## Conclusion

Following these steps will help you customize the Windows 11 taskbar using Intune MEM. For further details, consult the [Microsoft Intune documentation](https://learn.microsoft.com/en-us/mem/intune).
