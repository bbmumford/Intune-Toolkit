# Windows Device Rename Scripts

Comprehensive solution for renaming Windows devices to organizational standards when Intune's built-in rename functionality fails or needs to be supplemented.

## 📁 Files

- **`Rename-Device.ps1`** - Standalone automated script for device renaming
  - ✅ Fully automated, no user prompts
  - ✅ Automatic truncation to character limits
  - ✅ Suitable for Intune Scripts or local execution
- **`DeviceRename_Detection.ps1`** - Intune remediation detection script
  - ✅ Fully automated, no user prompts
  - ✅ Purpose-built for Intune Proactive Remediations
- **`DeviceRename_Remediation.ps1`** - Intune remediation script
  - ✅ Fully automated, no user prompts
  - ✅ Purpose-built for Intune Proactive Remediations
- **`README.md`** - This documentation
- **`FALLBACK_LOGIC.md`** - Technical reference for identifier fallback hierarchy

## 🎯 Purpose

These scripts rename Windows devices to follow the format: **`{OrgShort}-{SerialNumber}`**

### Examples:
- `ACME-ABC12345678`
- `CONTOSO-1234567890`
- `COMP-SN123456`

This is useful when:
- Intune's built-in device rename action fails
- You need consistent naming across all devices
- AutoPilot devices need standardized names
- Migrating from on-premises AD to Intune

## 🚀 Deployment Options

### Deployment Method Comparison

| Feature | Proactive Remediation | Intune Scripts | Local Execution |
|---------|----------------------|----------------|-----------------|
| **Scripts Used** | Detection + Remediation | Rename-Device.ps1 | Rename-Device.ps1 |
| **User Prompts** | ❌ None | ❌ None | ❌ None |
| **Automatic Truncation** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Continuous Compliance** | ✅ Scheduled checks | ❌ One-time run | ❌ Manual |
| **Restart Handling** | Via Intune policy | Via Intune policy | Manual |
| **Best For** | Fleet-wide compliance | One-time mass rename | Testing/Manual fixes |
| **Recommended** | ⭐⭐⭐ **Primary** | ⭐⭐ Secondary | ⭐ Testing only |

**All scripts are fully automated with no user interaction required.**

---

### Option 1: Intune Proactive Remediation (Recommended)

This automatically detects and fixes non-compliant device names across your fleet.

#### Steps:

1. **Sign in to [Microsoft Intune admin center](https://intune.microsoft.com)**

2. **Navigate to Remediations**
   - Go to **Devices** > **Remediations** (or **Scripts and remediations**)
   - Click **+ Create script package**

3. **Basics**
   - **Name**: `Device Name Compliance - {OrgShort} Standard`
   - **Description**: `Ensures devices are named in {OrgShort}-{SerialNumber} format`

4. **Settings**

   **Detection script:**
   - Upload: `DeviceRename_Detection.ps1`
   - **IMPORTANT**: Edit the script first and change `$OrgShort = "ORG"` to your organization prefix
   - **Run this script using the logged-on credentials**: No
   - **Enforce script signature check**: No
   - **Run script in 64-bit PowerShell**: Yes

   **Remediation script:**
   - Upload: `DeviceRename_Remediation.ps1`
   - **IMPORTANT**: Edit the script first and change `$OrgShort = "ORG"` to your organization prefix
   - **Run this script using the logged-on credentials**: No
   - **Enforce script signature check**: No
   - **Run script in 64-bit PowerShell**: Yes

5. **Scope Tags**
   - Configure as needed for your organization

6. **Assignments**
   - Assign to device groups (e.g., "All Windows Devices" or specific AutoPilot groups)
   - **Schedule**: 
     - Run **Daily** until all devices are renamed
     - Then change to **Weekly** for ongoing compliance
   - Run immediately after assignment for testing

7. **Configure Restart Behavior** (Optional but Recommended)
   - Since device renames require a restart, configure a **Device Configuration** policy:
   - **Devices** > **Configuration profiles** > **Create profile**
   - Platform: **Windows 10 and later**
   - Profile type: **Settings catalog**
   - Add setting: **Update** > **Configure Deadline Grace Period** (e.g., 2 days)
   - This gives users time to save work before automatic restart

---

### Option 2: Manual Deployment via Intune Scripts

Deploy as a one-time execution script for specific devices.

#### Steps:

1. **Edit the Script**
   - Open `Rename-Device.ps1`
   - Change line 40: `[string]$OrgShort = "ORG"` to your organization prefix

2. **Deploy via Intune**
   - Navigate to **Devices** > **Scripts** > **Add** > **Windows 10 and later**
   - Upload: `Rename-Device.ps1`
   - **Run this script using the logged on credentials**: No
   - **Enforce script signature check**: No
   - **Run script in 64-bit PowerShell Host**: Yes
   - Assign to target devices or groups

3. **Monitor Execution**
   - Check **Device status** for success/failure
   - Review logs for any errors

**Note:** Script runs fully automated with no user prompts. For continuous compliance monitoring, use the Proactive Remediation method (Option 1).

---

### Option 3: Local Execution (Testing)

For testing on individual devices before mass deployment.

#### Steps:

1. **Copy script to device**
   ```powershell
   # Save Rename-Device.ps1 to C:\Temp\
   ```

2. **Open PowerShell as Administrator**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   ```

3. **Run the script**
   ```powershell
   cd C:\Temp
   .\Rename-Device.ps1 -OrgShort "ACME"
   ```

**Note:** Script runs automatically with no prompts. Restart device manually after completion.

---

## ⚙️ Configuration

### Required Configuration (Before Deployment)

**Both detection and remediation scripts** require you to set your organization prefix:

```powershell
# Change this line in BOTH scripts:
$OrgShort = "ORG"  # Change to "ACME", "CONTOSO", etc.
```

### Optional Configuration

**Maximum Name Length** (default: 15 characters)
```powershell
$MaxNameLength = 15  # Windows NetBIOS limit
```

**Truncation Behavior:**
- If `{OrgShort}-{SerialNumber}` exceeds 15 characters:
  1. Prefix is truncated first (keeps full serial if possible)
  2. If still too long, serial number is truncated
  3. Example: `VERYLONGORG-ABC123456789` → `VERYLO-ABC123456789`
- **Truncation is automatic** - no user prompts or manual intervention required
- Scripts log truncation actions for audit purposes
- All trailing hyphens are automatically removed after truncation

**Device Identifier Fallback (v1.1+):**
- Scripts automatically handle devices without valid serial numbers
- Fallback hierarchy (tries each in order):
  1. **BIOS Serial Number** (primary method)
  2. **UUID** (Computer System Product UUID, last 12 chars)
  3. **MAC Address** (first enabled network adapter, sanitized)
  4. **Random Identifier** (UN prefix + 8 random chars, e.g., UN1A2B3C4D)
- All scripts use the **same logic** to ensure consistency
- Particularly useful for:
  - Virtual machines (Hyper-V, VMware, VirtualBox)
  - Devices with missing/invalid serial numbers
  - Test environments
- **UN prefix** indicates "Unknown" device identifier (fallback used)

---

## 🔍 How It Works

### Device Identifier Resolution

**Primary Method:**
```powershell
# BIOS Serial Number
$serial = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
```

**Fallback Method 1 - UUID:**
```powershell
# Use last 12 characters of Computer System Product UUID
$uuid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID
$serial = ($uuid -replace '-', '').Substring([Math]::Max(0, $uuid.Length - 12))
# Example: 12345678-90AB-CDEF-1234-567890ABCDEF → 567890ABCDEF
```

**Fallback Method 2 - MAC Address:**
```powershell
# Use MAC address of first enabled network adapter
$mac = (Get-CimInstance Win32_NetworkAdapterConfiguration | 
        Where-Object { $_.IPEnabled }).MACAddress
$serial = $mac -replace ':', '' -replace '-', ''
# Example: 00:15:5D:01:02:03 → 00155D010203
```

**Fallback Method 3 - Random Identifier:**
```powershell
# Generate random 8-character alphanumeric string with UN prefix
$random = -join ((48..57) + (65..90) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$serial = "UN$random"
# Example: UN1A2B3C4D, UNEF5678AB, UN9Z4K7M2P
# UN = Unknown (indicates fallback was used)
# Result: ACME-UN1A2B3C4D
```

### Detection Logic

1. Gets current computer name
2. Retrieves device serial number from BIOS
3. Constructs expected name: `{OrgShort}-{SerialNumber}`
4. Compares current name to expected name
5. **Exit 0** = Compliant (names match)
6. **Exit 1** = Non-compliant (triggers remediation)

### Remediation Logic

1. Triggered when detection returns Exit 1
2. Retrieves serial number
3. Constructs new name
4. Performs rename using `Rename-Computer` cmdlet
5. If primary method fails, tries WMI method as fallback
6. **Exit 0** = Success
7. **Exit 1** = Failure (check logs)

### Restart Requirement

⚠️ **Device restart is required** for the name change to take effect.

Options:
- **Intune automatic restart** - Configure via device configuration policy
- **User-initiated restart** - Notify users to restart within grace period
- **Script-triggered restart** - Standalone script can prompt for immediate restart

---

## 📊 Monitoring Results

### Intune Remediation Dashboard

1. Go to **Devices** > **Remediations**
2. Click on your remediation package
3. View:
   - **Device status**: Shows compliant vs. non-compliant devices
   - **Detection results**: Devices that need remediation
   - **Remediation results**: Success/failure of rename operations

### Per-Device Logs

1. Click on individual devices in the remediation status
2. View script output including:
   - Current device name
   - Expected device name
   - Serial number
   - Rename operation result
   - Any errors encountered

### Example Output

**Detection (Compliant):**
```
Current computer name: ACME-ABC12345678
Device serial number: ABC12345678
Expected computer name: ACME-ABC12345678
COMPLIANT: Device name matches expected format
Device is correctly named as: ACME-ABC12345678
```

**Remediation (Success):**
```
=== Device Rename Remediation Started ===
Current computer name: DESKTOP-ABC123
Device serial number: ABC12345678
New computer name will be: ACME-ABC12345678
Renaming computer from 'DESKTOP-ABC123' to 'ACME-ABC12345678'...
SUCCESS: Computer renamed to ACME-ABC12345678
INFO: A restart is required for the name change to take effect
```

---

## 🛠️ Troubleshooting

### Issue: Script fails with "not authorized"

**Solution:**
- Ensure remediation is set to run as **SYSTEM** (not user context)
- Check: "Run this script using the logged-on credentials" should be **No**

### Issue: Serial number is invalid or empty

**Possible causes:**
- Virtual machines may have generic/empty serial numbers
- Some manufacturers use special characters
- Hyper-V or other hypervisors with default configurations

**Solution:**
- **Scripts now include automatic fallback methods** (v1.1+):
  1. **Primary**: BIOS Serial Number
  2. **Fallback 1**: UUID (Computer System Product)
  3. **Fallback 2**: MAC Address (first enabled network adapter)
  4. **Fallback 3**: Random identifier (UN + 8 random chars)

- The scripts will automatically try each method in order
- Check logs to see which identifier was used:
  ```
  WARNING: BIOS serial number is empty, trying fallback methods...
  Using UUID-based identifier: A1B2C3D4E5F6
  ```

- **For VMs specifically**, the UUID or MAC address is typically used
- **UN prefix** (e.g., `ACME-UN1A2B3C4D`) indicates a random identifier was generated
  - UN = "Unknown" device
  - Only used when all hardware identifiers fail
  - Each script run generates a NEW random ID (detection will trigger remediation)
- All three scripts (standalone, detection, remediation) use the **same fallback logic** ensuring consistency

### Issue: Name exceeds 15 characters

**Solution:**
- Script automatically truncates (prefix first, then serial)
- Use shorter organization prefix
- Modify `$MaxNameLength` if needed (not recommended - Windows limit is 15)

### Issue: Rename succeeds but name doesn't change

**Cause:** Device not restarted

**Solution:**
- Configure automatic restart policy in Intune
- Or manually restart the device
- Check pending rename: `(Get-CimInstance Win32_ComputerSystem).PendingComputerRename`

### Issue: Script runs but device still shows as non-compliant

**Possible causes:**
1. Device not restarted yet (pending rename)
2. Detection script configuration doesn't match remediation script
3. Serial number contains special characters causing mismatch

**Solution:**
- Ensure both scripts use **identical** `$OrgShort` values
- Check device logs for actual serial number retrieved
- Verify device has been restarted

### Issue: Remediation fails with WMI error

**Solution:**
- Script includes fallback WMI method
- If both methods fail, check Windows licensing/activation
- Verify no group policy restrictions on computer rename

---

## 🔒 Security Considerations

- ✅ Scripts run as **SYSTEM** account (required for rename)
- ✅ No external dependencies or downloads
- ✅ Uses native Windows PowerShell cmdlets only
- ✅ Sanitizes input to prevent injection
- ✅ No credentials or sensitive data stored
- ⚠️ Consider **script signature enforcement** for production (requires code signing)

---

## 📋 Best Practices

1. **Test first** - Deploy to pilot group before organization-wide rollout
2. **Match configurations** - Ensure detection and remediation use same `$OrgShort`
3. **Schedule wisely** - Run during maintenance windows if possible
4. **Monitor actively** - Watch remediation dashboard for first 48 hours
5. **User communication** - Notify users about required restarts
6. **Document exceptions** - Some devices (VMs, test devices) may need exclusion
7. **Version control** - Keep track of script modifications in git

---

## 📚 Related Intune Features

### Intune Built-in Device Rename

Intune has native device rename functionality:
- **Devices** > Select device > **Rename**
- Supports templates: `{{serialnumber}}`, `{{rand:5}}`, etc.
- **When to use Intune native**: For one-off renames or small batches
- **When to use these scripts**: When native rename fails, for bulk operations, or for automated compliance checking

### Dynamic Device Groups

Create groups based on device naming:
```
(device.displayName -startsWith "ACME-")
```

This allows automatic grouping of properly named devices for policy targeting.

---

## 🔄 Updates and Maintenance

**Version History:**
- **v1.1** - Added automatic fallback methods for devices without valid serial numbers (VMs, etc.)
  - Fallback 1: UUID-based identifier
  - Fallback 2: MAC address-based identifier
  - Fallback 3: Random identifier with UN prefix
  - Removed all user prompts for fully automated execution
  - Automatic truncation with no user interaction required
- **v1.0** - Initial release with detection, remediation, and standalone scripts

**Future Enhancements:**
- Support for custom naming templates
- Integration with Azure naming conventions
- Validation against organizational naming policies

---

## 💡 Examples

### Example 1: Standard Deployment
**Organization**: Contoso  
**Serial Number**: 1234567890  
**Result**: `CONTOSO-1234567890`

### Example 2: Long Organization Name
**Organization**: VERYLONGCOMPANY  
**Serial Number**: ABC123456789  
**Name Length**: 27 characters (exceeds limit)  
**Result**: `VERYLO-ABC123456789` (truncated to 15 chars)

### Example 3: Special Characters in Serial
**Organization**: ACME  
**Serial Number**: ABC/123-456  
**Result**: `ACME-ABC123456` (sanitized)

### Example 4: Random Identifier (No Hardware ID)
**Organization**: ACME  
**Serial Number**: (none - using random fallback)  
**Generated ID**: UN1A2B3C4D  
**Result**: `ACME-UN1A2B3C4D` (15 characters - perfect fit!)

### Example 5: Long Org Name with Random ID
**Organization**: VERYLONGCOMPANY  
**Generated ID**: UN9Z4K7M2P  
**Name Length**: 26 characters (exceeds limit)  
**Result**: `VERL-UN9Z4K7M2P` (truncated to 15 chars)

---

## 🆘 Support

For issues or questions:
1. Check **Troubleshooting** section above
2. Review Intune device logs
3. Test locally with verbose output
4. Check [Microsoft Intune documentation](https://learn.microsoft.com/en-us/mem/intune/)

---

## 📄 License

Part of the **Intune Toolkit** - Open source scripts for IT administrators.

**Disclaimer**: Test thoroughly before production deployment. No warranty provided.
