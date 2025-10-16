# Local Administrator Account Configuration

Intune Proactive Remediation scripts to configure and standardize the local Administrator account across Windows devices.

## 📁 Files

- **`LocalAdministrators_Detection.ps1`** - Detects if local Administrator account is properly configured
- **`LocalAdministrators_Remediation.ps1`** - Renames and enables the default Administrator account
- **`README.md`** - This documentation

## 🎯 Purpose

These scripts ensure:
- ✅ Default built-in Administrator account (SID *-500) is renamed to a standard name
- ✅ Account is enabled
- ✅ Account is in the Administrators group
- ✅ No duplicate accounts exist with the same name
- ✅ Compatible with Windows 7/8/10/11 and all PowerShell versions

### What It Does

**Example transformation:**
- **Before**: Account named "Administrator" (disabled)
- **After**: Account named "Company.LocalAdmin" (enabled)

## ⚙️ Configuration

**Before deployment, edit BOTH scripts and change the account name:**

```powershell
# In BOTH Detection and Remediation scripts, change this line:
$NewAdminName = "Company.LocalAdmin"  # Change to your organization's standard

# Examples:
$NewAdminName = "ACME.Admin"
$NewAdminName = "LocalAdmin"
$NewAdminName = "IT.Administrator"
```

## 🚀 Deployment via Intune

### 1. Sign in to Microsoft Intune Admin Center
Navigate to [https://intune.microsoft.com](https://intune.microsoft.com)

### 2. Create Proactive Remediation

1. Go to **Devices** > **Remediations** (or **Scripts and remediations**)
2. Click **+ Create script package**

### 3. Configure Basics

- **Name**: `Local Administrator Account Configuration`
- **Description**: `Renames and enables the default Administrator account to organizational standard`

### 4. Configure Settings

**Detection script:**
- Upload: `LocalAdministrators_Detection.ps1`
- **IMPORTANT**: Edit script first and change `$ExpectedAdminName` to your account name
- **Run this script using the logged-on credentials**: No
- **Enforce script signature check**: No
- **Run script in 64-bit PowerShell**: Yes

**Remediation script:**
- Upload: `LocalAdministrators_Remediation.ps1`
- **IMPORTANT**: Edit script first and change `$NewAdminName` to your account name (must match detection)
- **Run this script using the logged-on credentials**: No
- **Enforce script signature check**: No
- **Run script in 64-bit PowerShell**: Yes

### 5. Scope Tags
Configure as needed for your organization

### 6. Assignments
- Assign to device groups (e.g., "All Windows Devices")
- **Schedule**: Run daily or weekly
- **Note**: This is typically a one-time fix, but ongoing checks ensure compliance

## 🔍 How It Works

### Detection Logic

1. Uses **WMI/CIM** (compatible with all Windows versions) instead of `Get-LocalUser`
2. Finds the default Administrator account by SID pattern `S-1-5-*-500`
3. Checks if it's renamed to the expected name
4. Checks if it's enabled
5. Verifies it's in the Administrators group
6. Checks for duplicate accounts with the target name

**Exit Codes:**
- `0` = Compliant (account is correctly configured)
- `1` = Non-Compliant (triggers remediation)

### Remediation Logic

1. Finds the default Administrator account (SID *-500)
2. Removes any duplicate accounts with the target name (if they exist)
3. Renames the default Administrator account to the specified name
4. Enables the account if it's disabled
5. Ensures the account is in the Administrators group

**Exit Codes:**
- `0` = Success (remediation completed)
- `1` = Failure (check logs for details)

## 🔧 Compatibility

### Windows Versions
- ✅ Windows 7
- ✅ Windows 8/8.1
- ✅ Windows 10 (all versions)
- ✅ Windows 11 (all versions)
- ✅ Windows Server 2008 R2+

### PowerShell Versions
- ✅ PowerShell 2.0+
- ✅ PowerShell 5.0/5.1
- ✅ PowerShell 7.x

### Why Not Use `Get-LocalUser`?

The `Get-LocalUser` cmdlet is only available in:
- PowerShell 5.1+ on Windows 10 1607+ and Windows Server 2016+
- Not available on Windows 7, 8, or older Windows 10 builds

**Our solution uses:**
- `Get-CimInstance` with `Win32_UserAccount` (universal compatibility)
- `[ADSI]` (WinNT provider) for account modifications (works everywhere)

## 📊 Monitoring Results

### View in Intune

1. Go to **Devices** > **Remediations**
2. Click on your remediation package
3. View:
   - **Device status**: Compliant vs. non-compliant devices
   - **Detection results**: Which devices need remediation
   - **Remediation results**: Success/failure of fixes

### Example Output

**Detection (Compliant):**
```
Compliant: Administrator account 'Company.LocalAdmin' is properly configured and is an administrator.
```

**Detection (Non-Compliant):**
```
Non-Compliant: Default Administrator account is named 'Administrator' (disabled), expected 'Company.LocalAdmin' (enabled).
```

**Remediation (Success):**
```
=== Local Administrator Remediation Started ===
Found default Administrator account: Administrator (SID: S-1-5-21-xxx-500)
Renaming 'Administrator' to 'Company.LocalAdmin'...
Successfully renamed to 'Company.LocalAdmin'
Enabling administrator account...
Administrator account enabled
Verifying Administrators group membership...
Account is already in Administrators group
=== Remediation Completed Successfully ===
Administrator account 'Company.LocalAdmin' is configured and enabled
```

## 🛠️ Troubleshooting

### Issue: "Get-LocalUser is not recognized"

**Cause:** Script is running on Windows 7/8 or older PowerShell version

**Solution:** ✅ Already fixed! Updated scripts use WMI/CIM instead

### Issue: Account already exists with the same name

**Cause:** A separate user account (not the default admin) has the target name

**Solution:** 
- Remediation script automatically removes duplicate accounts
- Only the default Administrator account (SID *-500) is renamed

### Issue: Remediation runs but account still disabled

**Possible causes:**
1. Group Policy is enforcing account state
2. Another script/process is reverting changes

**Solution:**
- Check for conflicting Group Policies
- Review Device Configuration profiles in Intune
- Check Windows Event Logs for account changes

### Issue: Cannot verify Administrators group membership

**Cause:** Permissions issue or group enumeration failed

**Solution:**
- Script logs a warning but continues
- Manually verify: `net localgroup Administrators`
- Account should still be in the group (default for SID *-500)

## 🔒 Security Considerations

### Default Administrator Account

**Why rename it?**
- ✅ Security through obscurity (attackers target "Administrator")
- ✅ Organizational standardization
- ✅ Easier to track in audit logs
- ✅ Compliance requirements

**Security best practices:**
- 🔐 Set a strong, unique password (use separate process/script)
- 🔐 Consider LAPS (Local Administrator Password Solution) for password management
- 🔐 Limit who knows the account name
- 🔐 Monitor usage through Windows Event Logs
- 🔐 Consider disabling if not needed (depends on organization policy)

### Script Permissions

- Scripts run as **SYSTEM** account (full privileges)
- No credentials stored in scripts
- Uses native Windows APIs only
- No external dependencies

## 📋 Best Practices

1. **Test first** - Deploy to pilot group before organization-wide rollout
2. **Match names** - Ensure detection and remediation use identical account names
3. **Password management** - Implement LAPS or similar solution separately
4. **Monitor actively** - Watch remediation dashboard for first week
5. **Document** - Keep record of standard account name for your organization
6. **Audit regularly** - Schedule periodic compliance checks

## 🔗 Related Intune Features

### LAPS (Local Administrator Password Solution)

Microsoft Intune now supports LAPS natively:
- **Devices** > **Configuration profiles** > **Account protection**
- Automatically manages local admin passwords
- Integrates with Azure AD
- Recommended to use alongside this script

**Workflow:**
1. Use these scripts to standardize account name
2. Configure LAPS to manage that account's password

### Account Protection Policies

Configure additional account policies:
- Password complexity requirements
- Account lockout policies
- Audit account usage

## 📚 Additional Resources

- [Microsoft Intune LAPS Guide](https://learn.microsoft.com/en-us/mem/intune/protect/windows-laps-overview)
- [Windows Built-in Administrator Account](https://learn.microsoft.com/en-us/windows/security/identity-protection/access-control/local-accounts#sec-administrator)
- [Intune Proactive Remediations](https://learn.microsoft.com/en-us/mem/analytics/proactive-remediations)

## 🔄 Version History

**v1.1** - Current
- Fixed compatibility issues with older Windows versions
- Replaced `Get-LocalUser` cmdlets with WMI/CIM
- Added Administrators group membership verification
- Added duplicate account detection and removal
- Enhanced error handling and logging
- Compatible with PowerShell 2.0+

**v1.0** - Original
- Initial version using `Get-LocalUser` cmdlets

## ⚠️ Important Notes

- **Restart not required** - Changes take effect immediately
- **Default admin SID** - Always targets SID ending in -500 (built-in Administrator)
- **Domain-joined devices** - Script only affects local accounts, not domain accounts
- **Duplicate accounts** - Automatically removed if they conflict with target name
- **Group membership** - Default Administrator account should always be in Administrators group

## 💡 Example Use Cases

### Standard Corporate Environment
```powershell
$NewAdminName = "ACME.LocalAdmin"
```
Result: All devices have standardized "ACME.LocalAdmin" account

### Multiple Subsidiaries
```powershell
# Company A devices
$NewAdminName = "CompanyA.Admin"

# Company B devices  
$NewAdminName = "CompanyB.Admin"
```
Deploy different remediation packages to different device groups

### IT Support Account
```powershell
$NewAdminName = "ITSupport.Admin"
```
Standardized account for IT help desk access

---

**Part of the Intune Toolkit** - Open source scripts for IT administrators
