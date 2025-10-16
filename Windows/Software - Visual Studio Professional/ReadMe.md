
# Intune App Deployment Guide: Visual Studio Professional

This guide provides step-by-step instructions for deploying VS Pro as a Win32 app in Microsoft Intune using the Software - TEMPLATE script.

## Steps to Deploy Visual Studio Professional

### 1. Prepare the Script (see Software -TEMPLATE)
The `Application_Downloader&Installer.ps1` script does not need modification. Instead, the app deployment can be configured dynamically using command-line arguments when deploying through Intune.

### 2. Package the Script (see Software -TEMPLATE)
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
   - **Name**: Visual Studio Professional
   - **Description**:
   - **Publisher**:

6. Configure the program settings:
You can find the different downloadable verisons https://learn.microsoft.com/en-us/visualstudio/install/create-a-network-installation-of-visual-studio?view=vs-2022#download-the-visual-studio-bootstrapper-to-create-the-layout
   
   #### Install Command:
   ```powershell
    powershell.exe -ExecutionPolicy Bypass -File ".\Application_Downloader&Installer.ps1" -DownloadUrl "https://aka.ms/vs/17/release/vs_professional.exe" -InstallerArgs "--quiet --norestart"
   ```

   --productID 'Microsoft.VisualStudio.Product.Professional' 

   #### Uninstall Command:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -Command "& { . '.\Application_Downloader&Installer.ps1' -DownloadUrl 'https://aka.ms/vs/17/release/vs_professional.exe' -InstallerArgs 'uninstall --installPath ''C:\Program Files\Microsoft Visual Studio\2022\Professional'' --quiet --norestart'; Start-Process -FilePath 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\InstallCleanup.exe' -Wait }"

   ```

7. Configure the **Detection Rules**:
   - **Rule Type**: File
   - **Path**: `C:\Program Files\Microsoft Visual Studio\2022\`
   - **File or Folder**: `Professional`
   - **Detection Method**: Exists

### Step 2: Assign the App

1. Assign the app to a group of users or devices.
2. Select assignment type as **Required** for automatic deployment.

### Step 3: Monitor Deployment

1. Go to **Apps > Monitor > App Install Status** to track the deployment status.
2. Verify that the application installs correctly on target devices.

---

This guide ensures a seamless deployment and management process for VS Pro using Intune.
