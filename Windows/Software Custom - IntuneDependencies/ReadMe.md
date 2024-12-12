# Deploying Intune Dependencies in Microsoft Intune as a Win32 App

This guide will walk you through the process of deploying Intune Dependecies in Microsoft Intune as a Win32 app. This script copies required files to `C:\IntuneDependencies` and updates a registry key for detection. Additionally, the `DeleteFiles.cmd` script removes the dependencies and cleans up the registry key.

---

## Prerequisites
1. **Intune Admin Access**.
2. **Win32 Content Prep Tool**: To create `.intunewin` packages.

---

## Steps to Deploy

### Step 1: Prepare the Scripts
1. Save the updated `CopyFiles.cmd` and `DeleteFiles.cmd` scripts.
2. Place all files to be copied (e.g., `Wallpaper.png`) in the same folder as `CopyFiles.cmd`.
3. Use the Intune Win32 Content Prep Tool to create `.intunewin` packages for both scripts:
   ```bash
   IntuneWinAppUtil.exe -c <source_folder> -s CopyFiles.cmd -o <output_folder>
   ```

---

### Step 2: Upload the App to Intune
1. Log in to the [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com).
2. Navigate to **Apps > All Apps** and select **Add**.
3. Choose **App type** as **Windows app (Win32)** and click **Select**.
4. Upload the `.intunewin` package for `CopyFiles.cmd`.
5. Repeat the process to upload the `.intunewin` package for `DeleteFiles.cmd` if needed.

---

### Step 3: Configure the App Information for `CopyFiles.cmd`
1. **Name**: `Copy Files Configuration`
2. **Description**: `Copies required files to C:\IntuneDependencies and sets a registry key for detection.`
3. Fill in any other required fields and click **Next**.

---

### Step 4: Set Program Details for `CopyFiles.cmd`
- **Install Command**:
  ```plaintext
  CopyFiles.cmd
  ```
- **Uninstall Command**:
  ```plaintext
  DeleteFiles.cmd
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
3. Run `DeleteFiles.cmd` to uninstall and clean up if needed.

---

## Troubleshooting
- **App Not Detected**: Ensure the registry key `HKLM:\Software\IntuneDependencies\DependenciesCopied` exists after running the script.
- **Log Location**: Check logs in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` for additional troubleshooting details.

---

By following these steps, you can deploy and monitor the `CopyFiles.cmd` and `DeleteFiles.cmd` scripts as Win32 apps in Intune.
