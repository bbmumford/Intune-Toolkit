# Deploying LoadingScreen.ps1 in Microsoft Intune as a Win32 App

This guide provides step-by-step instructions to deploy the `LoadingScreen.ps1` script in Microsoft Intune as a Win32 app. The script updates the loading screen settings and uses a registry key for detection.

---

## Prerequisites
1. **Intune Admin Access**.
2. **Win32 Content Prep Tool**: Required to package the `.ps1` script for deployment.

---

## Steps to Deploy

### Step 1: Prepare the Script
1. Save the script as `LoadingScreen.ps1`.
2. Create a new folder (e.g., `LoadingScreenDeployment`) and place the script in it.
3. Use the Intune Win32 Content Prep Tool to create a `.intunewin` package:
   ```bash
   IntuneWinAppUtil.exe -c <source_folder> -s LoadingScreen.ps1 -o <output_folder>
   ```

---

### Step 2: Upload the App to Intune
1. Log in to the [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com).
2. Navigate to **Apps > All Apps** and click **Add**.
3. Select **Windows app (Win32)** as the **App type** and click **Select**.
4. Upload the `.intunewin` package created earlier.

---

### Step 3: Configure the App Information
1. **Name**: `Loading Screen Configuration`
2. **Description**: `Configures the device loading screen and sets the necessary registry keys for detection.`
3. Fill in any other required fields, then click **Next**.

---

### Step 4: Set Program Details
- **Install Command**:
  ```plaintext
  powershell.exe -ExecutionPolicy Bypass -File .\LoadingScreen.ps1
  ```
- **Uninstall Command**:
  ```plaintext
  powershell.exe -Command "Remove-ItemProperty -Path HKLM:\Software\LoadingScreen -Name DeviceConfigurationComplete -Force"
  ```

---

### Step 5: Configure Detection Rules
1. Choose **Detection Rule Type**: **Registry**.
2. **Path**: `HKLM\Software\LoadingScreen`
3. **Key**: `DeviceConfigurationComplete`
4. **Value Type**: `String`
5. Specify that the value must exist.

---

### Step 6: Assign the App
1. Assign the app to the appropriate group of devices or users.
2. Configure any requirements and dependencies as needed.
3. Review and finalize the configuration.

---

### Step 7: Monitor Deployment
1. Go to **Devices > Monitor > App Install Status** to track the deployment.
2. Verify the presence of the registry key `HKLM:\Software\LoadingScreen\DeviceConfigurationComplete` on target devices to confirm a successful installation.

---

## Troubleshooting
- **App Not Detected**: Ensure the registry key exists and matches the detection criteria.
- **Script Errors**: Review logs in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` for troubleshooting.
- **Uninstall Issues**: Verify that the `DeviceConfigurationComplete` registry key is removed after running the uninstall command.

---

By following these steps, you can deploy the `LoadingScreen.ps1` script as a Win32 app in Microsoft Intune and monitor its deployment and success.
