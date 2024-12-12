# Deploying Intune Dependencies in Microsoft Intune as a Win32 App

This guide will walk you through the process of deploying the `CopyFiles.cmd` script in Microsoft Intune as a Win32 app. This script copies required files to `C:\IntuneDependencies` and updates a registry key for detection.

---

## Prerequisites
1. **Intune Admin Access**.
2. **Win32 Content Prep Tool**: To create an `.intunewin` package.

---

## Steps to Deploy

### Step 1: Prepare the Script
1. Save the updated script as `CopyFiles.cmd`.
2. Place all files to be copied (e.g., `Wallpaper.png`) in the same folder as `CopyFiles.cmd`.
3. Use the Intune Win32 Content Prep Tool to create a `.intunewin` package from your script:
   ```bash
   IntuneWinAppUtil.exe -c <source_folder> -s CopyFiles.cmd -o <output_folder>
   ```

---

### Step 2: Upload the App to Intune
1. Log in to the [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com).
2. Navigate to **Apps > All Apps** and select **Add**.
3. Choose **App type** as **Windows app (Win32)** and click **Select**.
4. Upload the `.intunewin` package created earlier.

---

### Step 3: Configure the App Information
1. **Name**: `Copy Files Configuration`
2. **Description**: `Copies required files to C:\IntuneDependencies and sets a registry key for detection.`
3. Fill in any other required fields and click **Next**.

---

### Step 4: Set Program Details
- **Install Command**:
  ```plaintext
  CopyFiles.cmd
  ```
- **Uninstall Command**:
  ```plaintext
  powershell.exe -Command "Remove-ItemProperty -Path HKLM:\Software\IntuneDependencies -Name DependenciesCopied -Force"
  ```

---

### Step 5: Configure Detection Rules
1. Choose **Detection Rule Type**: **Registry**.
2. **Path**: `HKLM\Software\IntuneDependencies`
3. **Key**: `DependenciesCopied`
4. **Value Type**: `String`
5. Specify that the value must exist.

---

### Step 6: Assign the App
1. Assign the app to the appropriate group of devices or users.
2. Set any necessary requirements and dependencies.
3. Review and finish the configuration.

---

### Step 7: Monitor Deployment
1. Go to **Devices > Monitor > App Install Status** to track the deployment status.
2. Verify that the registry key is created on the device to confirm the installation was successful.

---

## Troubleshooting
- **App Not Detected**: Ensure the registry key `HKLM:\Software\IntuneDependencies\DependenciesCopied` exists after running the script.
- **Log Location**: Check logs in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` for additional troubleshooting details.

---

By following these steps, you can deploy and monitor the updated `CopyFiles.cmd` script as a Win32 app in Intune.
