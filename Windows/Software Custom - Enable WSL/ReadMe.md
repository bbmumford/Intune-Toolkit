
# Guide: Adding Windows Subsystem for Linux (WSL) to Intune

This guide walks you through packaging and deploying a Win32 app for enabling Windows Subsystem for Linux (WSL) on managed Windows devices using Microsoft Intune.

---

## Prerequisites

1. **Admin Rights**: Ensure you have administrative privileges to access the Intune admin center.
2. **Microsoft Win32 Content Prep Tool**: [Download the tool here](https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management#prepare-the-win32-app-content).
3. **PowerShell Scripts**:
   - **Installation Script**: `WSL.ps1`
   - **Detection Script**: `Detection.ps1`

---

## Steps to Add WSL to Intune

### 1. Prepare the Win32 App Package

1. **Organize Files**:
   - Create a folder containing the following files:
     - `WSL.ps1` (installation script)
     - `Detection.ps1` (detection script)
   
2. **Package the App**:
   - Download and extract the Microsoft Win32 Content Prep Tool.
   - Run the following command to create the `.intunewin` package:
     ```powershell
     IntuneWinAppUtil.exe -c <Path to folder with scripts> -s WSL.ps1 -o <Output folder>
     ```
   - Example:
     ```powershell
     IntuneWinAppUtil.exe -c C:\WSLDeployment -s WSL.ps1 -o C:\WSLOutput
     ```
   - The output will include a file like `InstallWSL.intunewin`.

### 2. Add the Win32 App to Intune

1. **Log into Intune**:
   - Go to [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com/).

2. **Navigate to Apps**:
   - Go to `Apps` > `All Apps` > `+ Add`.

3. **Choose App Type**:
   - Select `Windows app (Win32)` as the app type.

4. **Upload the Package**:
   - Under `App package file`, click `Select file` and upload the `.intunewin` file created earlier.
   - Click `OK` to proceed.

5. **Configure App Information**:
   - Fill in the app details:
     - **Name**: Windows Subsystem for Linux (WSL)
     - **Publisher**: Internal IT
     - **Description**: Deploy WSL with Ubuntu to managed devices.
   - Click `Next`.

6. **Define Program**:
   - **Install Command**:
     ```powershell
     powershell.exe -ExecutionPolicy Bypass -File WSL.ps1 -Install -SkipDistroInstall
     ```
   - **Uninstall Command**:
     ```powershell
     powershell.exe -ExecutionPolicy Bypass -File WSL.ps1 -Uninstall
     ```
   - Click `Next`.

7. **Set Detection Rules**:
   - Choose `Custom detection script`.
   - Upload `Detection.ps1` as the detection script.
   - Click `Next`.

8. **Specify Requirements**:
   - Architecture: `64-bit`.
   - Minimum Operating System: `Windows 10 2004` or later.
   - Click `Next`.

9. **Define Assignments**:
   - Assign the app to specific device or user groups.
   - Click `Next`.

10. **Review and Create**:
    - Review your configuration and click `Create`.

---

## Validation

1. **Monitor Deployment**:
   - Go to `Apps` > `All Apps` and select your WSL app.
   - Check the `Device Install Status` and `User Install Status`.

2. **Verify Installation**:
   - On a target device, open PowerShell and run:
     ```powershell
     wsl --list --verbose
     ```
   - Ensure WSL is enabled and Ubuntu is installed.

---

## Troubleshooting

- **Deployment Failed**:
  - Verify the detection script matches the expected WSL installation state.
  - Ensure the device meets the prerequisites.

- **Missing WSL Features**:
  - Confirm the scripts have proper execution policies and administrative rights.

---

## Additional Resources

- [Microsoft WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Microsoft Intune Win32 App Deployment](https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management)

