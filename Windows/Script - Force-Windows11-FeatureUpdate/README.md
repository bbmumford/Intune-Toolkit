# Force Windows 11 Feature Update Script

## Overview

This script package forces a Windows 11 feature update installation by downloading and executing the official Microsoft Windows 11 Installation Assistant. This is useful when:

- Windows Update is stuck or broken
- Component store corruption prevents normal updates
- Feature updates fail repeatedly through standard Windows Update
- Devices are significantly behind on feature updates

## How It Works

The script bypasses the standard Windows Update mechanism by:

1. **Downloading** the official Windows 11 Installation Assistant from Microsoft
2. **Performing an in-place upgrade** that preserves all apps, data, and settings
3. **Automatically restarting** the device when ready

This method effectively reinstalls Windows while keeping everything intact, which resolves most update-related corruption issues.

## Files Included

| File | Purpose |
|------|---------|
| `Force-Windows11FeatureUpdate.ps1` | Main remediation script that downloads and runs the upgrade |
| `Force-Windows11FeatureUpdate_Detection.ps1` | Detection script for Proactive Remediation (optional) |

## Requirements

- Windows 10 21H2+ or Windows 11
- PowerShell 5.1+
- 64-bit operating system
- Minimum 10GB free disk space
- Active internet connection
- TPM 2.0 (for Windows 11 compliance)
- Secure Boot enabled (for Windows 11 compliance)
- Run as SYSTEM (Administrator privileges)

## Deployment Options

### Option 1: Intune Platform Script (Recommended for Immediate Deployment)

1. Navigate to **Intune Admin Center** → **Devices** → **Scripts and remediations** → **Platform scripts**
2. Create a new Windows script
3. Upload `Force-Windows11FeatureUpdate.ps1`
4. Configure:
   - Run this script using the logged-on credentials: **No**
   - Enforce script signature check: **No**
   - Run script in 64-bit PowerShell: **Yes**
5. Assign to target device groups

### Option 2: Intune Proactive Remediation (Recommended for Ongoing Compliance)

1. Navigate to **Intune Admin Center** → **Devices** → **Scripts and remediations** → **Remediations**
2. Create a new remediation
3. Upload:
   - Detection script: `Force-Windows11FeatureUpdate_Detection.ps1`
   - Remediation script: `Force-Windows11FeatureUpdate.ps1`
4. Configure:
   - Run this script using the logged-on credentials: **No**
   - Enforce script signature check: **No**
   - Run script in 64-bit PowerShell: **Yes**
5. Set schedule (e.g., daily or weekly)
6. Assign to target device groups

## Configuration

### Main Script Configuration

Edit the following variables in `Force-Windows11FeatureUpdate.ps1`:

```powershell
# Minimum free space required (in GB)
$MinFreeSpaceGB = 10

# Download timeout in seconds
$DownloadTimeout = 600
```

### Detection Script Configuration

Edit the following variables in `Force-Windows11FeatureUpdate_Detection.ps1`:

```powershell
# Minimum required Windows 11 build number
# Windows 11 23H2 = 22631
# Windows 11 24H2 = 26100
$MinimumBuild = 22631

# Maximum days since last successful update
$MaxDaysSinceUpdate = 60

# Check for Windows Update service issues
$CheckUpdateHealth = $true
```

## Windows 11 Build Reference

| Version | Build Number | Release Date |
|---------|--------------|--------------|
| Windows 11 21H2 | 22000 | Oct 2021 |
| Windows 11 22H2 | 22621 | Sep 2022 |
| Windows 11 23H2 | 22631 | Oct 2023 |
| Windows 11 24H2 | 26100 | Oct 2024 |

## Exit Codes

### Main Script
| Code | Description |
|------|-------------|
| 0 | Upgrade initiated successfully |
| 1 | Prerequisite check failed |
| 2 | Download failed |
| 3 | Installation failed |

### Detection Script
| Code | Description |
|------|-------------|
| 0 | Compliant - no remediation needed |
| 1 | Non-compliant - remediation required |

## Log Files

Logs are written to: `C:\ProgramData\WindowsUpgrade\Windows11Upgrade_<timestamp>.log`

## What Gets Preserved

The in-place upgrade preserves:
- ✅ All installed applications
- ✅ User data and profiles
- ✅ System settings
- ✅ Network configurations
- ✅ Device drivers (compatible ones)

## What Happens During Upgrade

1. Script downloads Windows 11 Installation Assistant (~4MB)
2. Installation Assistant downloads Windows 11 files (~4-5GB)
3. System prepares for upgrade
4. Device restarts automatically
5. Upgrade installs (30-90 minutes depending on hardware)
6. Device boots into updated Windows 11

## Troubleshooting

### Upgrade Fails to Start
- Check prerequisites: TPM, Secure Boot, disk space
- Review log file at `C:\ProgramData\WindowsUpgrade\`
- Verify internet connectivity to Microsoft servers

### Download Fails
- Check firewall/proxy settings for `go.microsoft.com`
- Ensure BITS service is running
- Try running script manually for verbose output

### Compatibility Issues
- The script includes `/Compat IgnoreWarning` to bypass soft blocks
- Hardware that doesn't meet Windows 11 requirements may still fail
- Check Windows 11 hardware requirements if upgrade fails

## Important Notes

⚠️ **WARNING**: This script will cause the device to restart automatically!

- Schedule deployment during maintenance windows
- Notify users before deployment
- The upgrade process can take 30-90 minutes
- Ensure devices are connected to power (laptops)
- Test on a pilot group before broad deployment

## Optional: Pre-Upgrade System Repair

To run DISM and SFC repairs before the upgrade, uncomment this line in the main script:

```powershell
# Invoke-WindowsRepairBeforeUpgrade
```

This can help resolve component store corruption before attempting the upgrade.

## Related Resources

- [Windows 11 Installation Assistant](https://www.microsoft.com/software-download/windows11)
- [Windows 11 System Requirements](https://www.microsoft.com/windows/windows-11-specifications)
- [Intune Platform Scripts Documentation](https://docs.microsoft.com/mem/intune/apps/intune-management-extension)
