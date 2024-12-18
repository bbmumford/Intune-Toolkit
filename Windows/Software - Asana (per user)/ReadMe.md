# Asana Deployment Guide using `Application_Downloader&Installer.ps1`

This guide will walk you through the process of deploying applications to Microsoft Intune using the provided script [`Application_Downloader&Installer.ps1`](https://github.com/bbmumford/Intune-Toolkit/blob/main/Windows/Software%20-%20TEMPLATE/Application_Downloader%26Installer.ps1).

---

## Prerequisites

1. **Download the Script**  
   Clone or download the script [`Application_Downloader&Installer.ps1`](https://github.com/bbmumford/Intune-Toolkit/blob/main/Windows/Software%20-%20TEMPLATE/Application_Downloader%26Installer.ps1).

2. **Windows App Preparation Tool**  
   Download the [Microsoft Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool). This utility converts your app installer and additional files into a `.intunewin` format required by Intune.

3. **Admin Rights**  
   Ensure you have admin rights on your machine to run the preparation tool and upload packages to Intune.

---

## Steps

### 1. Prepare the Script
The `Application_Downloader&Installer.ps1` script does not need modification. Instead, the app deployment can be configured dynamically using command-line arguments when deploying through Intune.

### 2. Package the Script
1. Place the script (`Application_Downloader&Installer.ps1`) in a folder.
2. Use the [Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) to convert the folder into a `.intunewin` package:
   - Open a Command Prompt as Administrator.
   - Run the following command:
     ```cmd
     IntuneWinAppUtil.exe -c <source_folder> -s Application_Downloader&Installer.ps1 -o <output_folder>
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
   - **Name**: Asana.
   - **Description**: Details about the application.
   - **Publisher**: Asana.

### 4. Configure Install and Uninstall Commands
- **Install Command**: Use the following command:
  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File ".\Application_Downloader&Installer.ps1" -DownloadUrl "https://desktop-downloads.asana.com/win32_x64/prod/latest/AsanaSetup.exe" -InstallerArgs "/s"
  ```

#### Explanation

Parameters:
- DownloadUrl: The URL from which to download the executable
- InstallerArgs: Additional arguments to pass to the installer.


Functions:
- Download-File: Downloads the file from the specified URL to a specified output path.
- Install-Application: Installs the application using the downloaded executable and additional arguments.


Main Script:
- Downloads the executable to the temporary directory.
- Installs the application with the additional arguments.
- Cleans up by removing the downloaded executable.

Run as **User**


#### To Uninstall:
`%USERPROFILE%\AppData\Local\Asana\Update.exe" --uninstall`


### 5. Assign the App
1. Assign the app to the appropriate groups or users:
- Navigate to Assignments in the app configuration.
- Add Required or Available for enrolled devices groups as needed.

### 6. Monitor Deployment
After assigning the app, monitor its deployment status in the Intune admin center under Devices > Monitor > App install status.

## Notes
- Ensure the download URL is accessible by the devices in your network.
- Test the `.intunewin` package and install command locally before deployment to Intune.
- Adjust the installer arguments (`-InstallerArgs`) as required by your application's installer.
For more information, refer to the Microsoft Intune Documentation.