# Windows Activation Remediation for Intune

This folder contains Intune Proactive Remediation scripts to detect and activate Windows 11 devices.

## Files

- **WindowsActivation_Detection.ps1** - Detects if Windows is activated
- **WindowsActivation_Remediation.ps1** - Activates Windows using HWID method

## Intune Deployment Instructions

### 1. Create Proactive Remediation in Intune

1. Sign in to [Microsoft Intune admin center](https://intune.microsoft.com)
2. Navigate to **Devices** > **Remediations** (or **Scripts and remediations**)
3. Click **+ Create script package**
4. Configure the following:

### 2. Basics
- **Name**: Windows Activation Check and Remediation
- **Description**: Detects non-activated Windows devices and applies HWID activation

### 3. Settings

**Detection script:**
- Upload: `WindowsActivation_Detection.ps1`
- **Run this script using the logged-on credentials**: No
- **Enforce script signature check**: No
- **Run script in 64-bit PowerShell**: Yes

**Remediation script:**
- Upload: `WindowsActivation_Remediation.ps1`
- **Run this script using the logged-on credentials**: No
- **Enforce script signature check**: No
- **Run script in 64-bit PowerShell**: Yes

### 4. Scope Tags
- Configure as needed for your organization

### 5. Assignments
- Assign to device groups containing Windows 11 devices
- **Schedule**: 
  - Run once or Daily (recommended: Daily until all devices are activated)
  - You can also run on-demand for testing

## Important Notes

⚠️ **Execution Policy**: Intune Proactive Remediations run with **Bypass** execution policy automatically, so these scripts will work even if execution policy is restricted on the device.

⚠️ **Administrator Privileges**: These scripts run as SYSTEM in Intune, which has the necessary privileges.

⚠️ **Internet Connection**: The remediation script requires internet access to download the activation tool from GitHub.

⚠️ **Activation Method**: Uses HWID (Hardware ID) digital license activation. This is permanent and survives OS reinstalls.

## Testing Locally (If Needed)

If you need to test these scripts locally and are encountering execution policy issues:

### Option 1: Set Execution Policy (Admin PowerShell)
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\WindowsActivation_Detection.ps1
```

### Option 2: Bypass for Single Execution
```powershell
PowerShell.exe -ExecutionPolicy Bypass -File .\WindowsActivation_Detection.ps1
```

### Option 3: Run as Admin with Bypass
```powershell
Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PWD\WindowsActivation_Detection.ps1`"" -Verb RunAs
```

## Monitoring Results

After deployment, monitor the remediation results in Intune:

1. Go to **Devices** > **Remediations**
2. Click on your remediation package
3. View:
   - **Device status**: Shows detection and remediation results
   - **Logs**: Click on individual devices to see script output

## Exit Codes

**Detection Script:**
- `0` = Windows is activated (compliant)
- `1` = Windows is not activated (triggers remediation)

**Remediation Script:**
- `0` = Success (activation completed)
- `1` = Failed (check device logs for details)

## Troubleshooting

**Scripts won't run locally:**
- This is expected - Intune Proactive Remediations bypass execution policy automatically
- If testing locally, use one of the bypass methods above

**Remediation fails:**
- Check device has internet connectivity
- Verify device can reach `raw.githubusercontent.com`
- Review device logs in Intune for specific error messages

**Activation doesn't persist:**
- HWID activation should be permanent
- Verify the device TPM is enabled
- Check Windows is genuine and eligible for activation
