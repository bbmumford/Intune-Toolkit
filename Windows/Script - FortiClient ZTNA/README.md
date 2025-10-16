# FortiClient ZTNA Registration

**Purpose:** Automated FortiClient ZTNA (Zero Trust Network Access) registration with Enterprise Management Server (EMS) using Intune Proactive Remediation.

---

## Overview

This script pair ensures FortiClient ZTNA clients are properly registered with your EMS by automatically configuring the invitation code. The detection script checks if the registration is correct, and the remediation script performs the registration if needed.

### What This Does

- **Detects** if FortiClient ZTNA invitation code is correctly configured
- **Remediates** by running FortiESNAC.exe to register with EMS
- **Verifies** registration succeeded by checking registry values
- **Handles** edge cases like "already registered" responses

---

## Files

| File | Purpose | Run As | Context |
|------|---------|--------|---------|
| `FortiClient-ZTNA_Detection.ps1` | Checks if invitation code is configured | System | 64-bit |
| `FortiClient-ZTNA_Remediation.ps1` | Registers FortiClient with EMS | System | 64-bit |

---

## Prerequisites

### Software Requirements

1. **FortiClient** with ZTNA component installed
   - FortiClient EMS or FortiClient with ZTNA license
   - FortiESNAC.exe must be present at:
     - `C:\Program Files\Fortinet\FortiClient\FortiESNAC.exe` (x64), OR
     - `C:\Program Files (x86)\Fortinet\FortiClient\FortiESNAC.exe` (x86)

2. **Windows 10/11** (64-bit)

3. **PowerShell 5.0+**

### Access Requirements

- **Intune Proactive Remediation** license
- **System-level** execution (runs as SYSTEM)
- **Network access** to EMS server (for registration)

---

## Configuration

### 1. Get Your Invitation Code from EMS

1. Log into **FortiClient EMS**
2. Navigate to **Endpoint Profiles** or **ZTNA** section
3. Find your **Invitation Code** (example: `EJ040Y6TN30BZ7ELWXFB20RWT4ILKJOD`)
4. Copy the invitation code

### 2. Update Scripts with Your Invitation Code

**In BOTH scripts, update this line:**

```powershell
# FortiClient ZTNA invitation code from EMS
$InvitationCode = 'YOUR_INVITATION_CODE_HERE'
```

**Example:**
```powershell
$InvitationCode = 'EJ040Y6TN30BZ7ELWXFB20RWT4ILKJOD'
```

> ⚠️ **Important:** The invitation code must match in BOTH Detection and Remediation scripts!

---

## Deployment - Intune Proactive Remediation

### Step 1: Create Proactive Remediation Package

1. Sign in to **Microsoft Intune Admin Center** (https://intune.microsoft.com)
2. Navigate to **Devices** → **Remediations** (under Proactive remediations)
3. Click **+ Create script package**

### Step 2: Configure Basics

- **Name:** `FortiClient ZTNA Registration`
- **Description:** `Ensures FortiClient ZTNA is registered with EMS using the correct invitation code`
- **Publisher:** Your organization name

### Step 3: Upload Scripts

**Detection script:**
- Upload `FortiClient-ZTNA_Detection.ps1`

**Remediation script:**
- Upload `FortiClient-ZTNA_Remediation.ps1`

### Step 4: Settings

| Setting | Value | Reason |
|---------|-------|--------|
| **Run this script using the logged-on credentials** | **No** | Must run as System to access HKLM registry |
| **Enforce script signature check** | No | Unless you sign scripts |
| **Run script in 64-bit PowerShell** | **Yes** | Required for FortiClient x64 installation |

### Step 5: Scope Tags

- Add appropriate scope tags for your environment (optional)

### Step 6: Assignments

**Assign to:**
- Device groups with FortiClient installed
- Or: All devices (if FortiClient is deployed everywhere)

**Schedule:**
- Recommended: **Daily** or **Every 4 hours**
- This ensures new devices get registered quickly

### Step 7: Review + Create

- Review settings
- Click **Create**

---

## How It Works

### Detection Flow

1. Checks if registry path exists: `HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC`
2. Reads `invitation_code` registry value
3. Compares with expected value
4. **Exit 0** if matches (Compliant)
5. **Exit 1** if missing or mismatched (Non-Compliant → triggers remediation)

### Remediation Flow

1. Checks if already compliant (early exit if already correct)
2. Locates `FortiESNAC.exe` (checks x64 and x86 paths)
3. Executes registration: `FortiESNAC.exe --register <invitation_code>`
4. Handles "already registered" responses as success
5. Waits 120 seconds for registration to complete
6. Verifies registry value updated correctly
7. **Exit 0** if successful, **Exit 1** if failed

---

## Verification

### Check Registration Status

**Via Registry:**
```powershell
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC' -Name invitation_code
```

**Via FortiClient UI:**
1. Open FortiClient console
2. Check **ZTNA** or **Zero Trust** tab
3. Verify connection to EMS

**Via Intune Portal:**
1. Navigate to **Devices** → **Remediations**
2. Select your script package
3. View **Device status** tab
4. Check for:
   - ✅ **Without issues** = Registered correctly
   - ⚠️ **With issues** = Registration failed

---

## Troubleshooting

### Issue: "FortiESNAC.exe not found"

**Cause:** FortiClient not installed or ZTNA component missing

**Solution:**
1. Verify FortiClient is installed
2. Ensure ZTNA component is included in installation
3. Check installation paths:
   ```powershell
   Test-Path 'C:\Program Files\Fortinet\FortiClient\FortiESNAC.exe'
   Test-Path 'C:\Program Files (x86)\Fortinet\FortiClient\FortiESNAC.exe'
   ```

### Issue: "Invitation code mismatch"

**Cause:** Wrong invitation code configured in script

**Solution:**
1. Verify invitation code in EMS
2. Update `$InvitationCode` variable in **both** scripts
3. Ensure no extra spaces or characters

### Issue: "Registration failed - already registered with different code"

**Cause:** Device previously registered with different EMS or code

**Solution:**
1. Manually unregister FortiClient ZTNA
2. Re-run remediation
3. Or use FortiClient console to change EMS connection

### Issue: "Script succeeds but device not showing in EMS"

**Cause:** Network connectivity or EMS configuration issue

**Solution:**
1. Verify network connectivity to EMS server
2. Check EMS firewall rules
3. Verify invitation code is still valid in EMS
4. Check FortiClient logs: `C:\Program Files\Fortinet\FortiClient\logs\`

### Check Detailed Logs

**Intune Proactive Remediation Logs:**
- Location: `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\`
- File: `IntuneManagementExtension.log`
- Search for: `FortiClient-ZTNA`

**FortiClient Logs:**
- Location: `C:\Program Files\Fortinet\FortiClient\logs\`
- Files: `ems.log`, `fctems.log`

---

## Registry Details

### Registry Path
```
HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC
```

### Registry Value
- **Name:** `invitation_code`
- **Type:** String (REG_SZ)
- **Value:** Your EMS invitation code

### Manual Verification
```powershell
# Check current value
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC' | Select-Object invitation_code

# Manually set (for testing)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC' -Name 'invitation_code' -Value 'YOUR_CODE'
```

---

## Testing

### Test Detection Locally
```powershell
# Run as Administrator
.\FortiClient-ZTNA_Detection.ps1
```

**Expected outputs:**
- **Compliant:** Exit code 0, message "Compliant: FortiClient ZTNA is properly registered"
- **Non-Compliant:** Exit code 1, message showing what's wrong

### Test Remediation Locally
```powershell
# Run as Administrator
.\FortiClient-ZTNA_Remediation.ps1
```

**Expected output:**
- Detailed registration process
- Exit code 0 on success
- Exit code 1 on failure with error details

### Clear Registration (for testing)
```powershell
# Remove registry value to test remediation
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC' -Name 'invitation_code' -Force
```

---

## Best Practices

1. **Test in pilot group first** before broad deployment
2. **Match invitation codes** in both scripts exactly
3. **Monitor for first week** after deployment
4. **Schedule reasonable frequency** (daily or every 4 hours)
5. **Document your invitation code** in a secure location
6. **Rotate invitation codes** periodically per security policy
7. **Update scripts** when rotating codes

---

## Security Considerations

- **Invitation code is sensitive** - treat as credential
- **Scripts run as SYSTEM** - they have elevated privileges
- **Registry is HKLM** - system-wide configuration
- **Consider scope tags** to limit deployment scope
- **Audit script changes** before deploying updates

---

## Related Documentation

- [FortiClient EMS Administration Guide](https://docs.fortinet.com/)
- [Intune Proactive Remediations](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations)
- [SCRIPT_HEADER_STANDARD.md](../SCRIPT_HEADER_STANDARD.md) - Script documentation standards
- [DETECTION_STRATEGY_GUIDE.md](../DETECTION_STRATEGY_GUIDE.md) - Detection methodology

---

## Support

**Issues or Questions:**
- Check FortiClient logs first
- Review Intune remediation device status
- Verify invitation code is correct
- Ensure FortiClient ZTNA component is installed

**Version:** 1.0  
**Last Updated:** 2025-10-17  
**Author:** Brandon Miller-Mumford
