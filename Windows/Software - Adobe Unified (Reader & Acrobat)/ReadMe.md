# Adobe Reader & Acrobat Deployment Guide.

This will automatically detect & use the correct license based on the provided credentials, defaulting to reader if non are provided.

## Steps

### 1. Prepare the Script
The `Install_AdobeUnified.ps1` script does not need modification. Instead, the app deployment can be configured dynamically using command-line arguments when deploying through Intune.

### 2. Package the Script
1. Place the script (`Install_AdobeUnified.ps1`) in a folder.
2. Use the [Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) to convert the folder into a `.intunewin` package:
   - Open a Command Prompt as Administrator.
   - Run the following command:
     ```cmd
     IntuneWinAppUtil.exe -c <source_folder> -s Install_AdobeUnified.ps1 -o <output_folder>
     ```
     Replace:
     - `<source_folder>`: Path to the folder containing the script.
     - `<output_folder>`: Path to save the `.intunewin` file.

### 3. Add the App to Intune
1. Go to the **Microsoft Intune admin center**: [https://endpoint.microsoft.com](https://endpoint.microsoft.com).
2. Navigate to **Apps** > **All apps** > **Add**.
3. Select **App type** as **Windows app (Win32)** and click **Select**.
4. Upload the `.intunewin` file generated in the previous step.
5. Configure the app details:
   - **Name**: Adobe DC Unified Installer
   - **Description**:
   - **Publisher**: Adobe

### 4. Configure Install and Uninstall Commands
- **Install Command**: Use the following command:
```powershell
  powershell.exe -ExecutionPolicy Bypass -File ".\Install_AdobeUnified.ps1"
```

**Uninstall Command**: 
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\.\UninstallAcrobatDC.ps1`
```

### 5. Assign the App
1. Assign the app to the appropriate groups or users:
- Navigate to Assignments in the app configuration.
- Add Required or Available for enrolled devices groups as needed.

### 6. Monitor Deployment
- After assigning the app, monitor its deployment status in the Intune admin center under Devices > Monitor > App install status.

## Notes
- Ensure the download URL is accessible by the devices in your network.
- Test the .intunewin package and install command locally before deployment to Intune.
- Adjust the installer arguments (-InstallerArgs) as required by your application's installer.
For more information, refer to the Microsoft Intune Documentation.