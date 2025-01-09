# Intune App Deployment Guide using `Application_Downloader&Installer.ps1`

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
   - **Name**: Name of the application.
   - **Description**: Details about the application.
   - **Publisher**: The application publisher.

### 4. Configure Install and Uninstall Commands
- **Install Command**: Use the following command, replacing `DOWNLOAD_LINK_HERE` with the direct link to the application's installer:
```powershell
  powershell.exe -ExecutionPolicy Bypass -File ".\Application_Downloader&Installer.ps1" -DownloadUrl "DOWNLOAD_LINK_HERE" -InstallerArgs "/qn /norestart"
```
#### Explanation

Parameters:
- DownloadUrl: The URL from which to download the MSI or EXE file.
- InstallerArgs: Additional arguments to pass to the installer.

Functions:
- Download-File: Downloads the file from the specified URL to a specified output path
- Install-Application: Installs the application using the downloaded MSI or EXE file and additional arguments.

Main Script:
- Downloads the file to the temporary directory.
- Installs the application with the additional arguments.
- Cleans up by removing the downloaded file.

**Uninstall Command**: The uninsatll script finds the correct GUID based off the appliation name then uninstalls the app based on if it is a msi or exe. Use the following:
```powershell
powershell.exe -ExecutionPolicy Bypass -File ".\Application_Uninstaller.ps1" -AppName "Application Name"
```

Some applications will include a uninstall flag with the installer, in that case you can reuse the installer script with an /uninstall argument, see below an example of `Logi Options+`
```powershell
powershell.exe -ExecutionPolicy Bypass -File ".\Application_Downloader&Installer.ps1" -DownloadUrl "https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer.exe" -InstallerArgs "/uninstall"
```

### 5. Assign the App
1. Assign the app to the appropriate groups or users:
- Navigate to Assignments in the app configuration.
- Add Required or Available for enrolled devices groups as needed.
### 6. Monitor Deployment
- After assigning the app, monitor its deployment status in the Intune admin center under Devices > Monitor > App install status.

### Notes
- Ensure the download URL is accessible by the devices in your network.
- Test the .intunewin package and install command locally before deployment to Intune.
- Adjust the installer arguments (-InstallerArgs) as required by your application's installer.
For more information, refer to the Microsoft Intune Documentation.