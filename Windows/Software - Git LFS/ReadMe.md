
# Intune App Deployment Guide: Git LFS (v3.6.0)

> [!NOTE]  
> Needs to be upgraded to use Software - TEMPLATE solution.

This guide provides step-by-step instructions for deploying Git LFS (v3.6.0) as a Win32 app in Microsoft Intune using a single command line for installation and uninstallation.

## Steps to Deploy Git LFS

### Step 1: Add the App in Intune

1. Log in to the [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).

2. Navigate to **Apps > All apps > Add > Windows app (Win32)**.
      *You will need to upload a blank Intunewin package.*

3. Configure the app details:
   - **Name**: Git LFS (v3.6.0)
   - **Description**: Git Large File Storage (v3.6.0) for Windows.
   - **Publisher**: GitHub

4. Configure the program settings:
   
   #### Install Command:
   ```bash
   powershell.exe -Command "Invoke-WebRequest -Uri 'https://github.com/git-lfs/git-lfs/releases/download/v3.6.0/git-lfs-windows-v3.6.0.exe' -OutFile '$env:TEMP\git-lfs-installer.exe'; Start-Process -FilePath '$env:TEMP\git-lfs-installer.exe' -ArgumentList '/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -Wait; git lfs install --system"
   ```

   #### Uninstall Command:
   ```bash
   "C:\Program Files\Git LFS\unins000.exe" /silent /norestart
   ```

5. Configure the **Detection Rules**:
   - **Rule Type**: File
   - **Path**: `C:\Program Files\Git LFS`
   - **File or Folder**: `git-lfs.exe`
   - **Detection Method**: Exists

### Step 2: Assign the App

1. Assign the app to a group of users or devices.
2. Select assignment type as **Required** for automatic deployment.

### Step 3: Monitor Deployment

1. Go to **Apps > Monitor > App Install Status** to track the deployment status.
2. Verify that the application installs correctly on target devices.

## Verification

1. On a client device, open a command prompt or PowerShell.
2. Run the following command to check Git LFS version:
   ```bash
   git lfs version
   ```
3. Verify that Git LFS is successfully installed and configured.

## Notes

- Ensure Git is installed on the target devices before deploying Git LFS.
- If any issues occur during deployment, check Intune logs and ensure the detection rules are correctly configured.

---

This guide ensures a seamless deployment and management process for Git LFS using Intune.
