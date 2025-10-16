# Scripts Folder Analysis for Intune-Toolkit Integration

**Analysis Date:** 2025-10-17  
**Source:** `/Users/local_admin/Library/CloudStorage/OneDrive-Personal/Scripts`  
**Target Repository:** Intune-Toolkit

---

## Executive Summary

After analyzing the Scripts folder, I've identified **3 scripts suitable for Intune-Toolkit** and **8 scripts that should remain separate** (Azure AVD automation/management).

### ✅ Recommended for Intune-Toolkit (3 scripts)

1. **FortiClient ZTNA Registration** (Detection + Remediation) - Intune Proactive Remediation
2. **OneDrive User Configuration** - User context configuration script

### ❌ Not Suitable for Intune-Toolkit (8+ scripts/files)

- **AVD Management Scripts** (5) - These are Azure Automation runbooks, not Intune scripts
- **Misc Admin Tools** (3+) - Exchange/Azure admin utilities, not endpoint management

---

## Detailed Analysis

### ✅ 1. FortiClient ZTNA Scripts - **HIGHLY RECOMMENDED**

**Location:** `FortiZTNA/`

#### Files:
- `Detect-ZTNA.ps1` (25 lines)
- `Remediate-ZTNA.ps1` (75 lines)

#### Purpose:
Intune Proactive Remediation pair that ensures FortiClient ZTNA is properly registered with the correct invitation code.

#### Analysis:
- **✅ Perfect fit:** Already structured as Intune Detection/Remediation pair
- **✅ Production ready:** Proper exit codes, error handling
- **✅ Follows standards:** Uses registry detection (checks actual state)
- **✅ Well documented:** Clear logic flow
- **✅ Useful:** Automates FortiClient ZTNA registration across endpoints

#### Implementation Details:

**Detection Logic:**
```powershell
# Checks: HKLM:\SOFTWARE\Fortinet\FortiClient\FA_ESNAC\invitation_code
# Exit 0 if matches expected value
# Exit 1 if missing or mismatched
```

**Remediation Logic:**
```powershell
# Runs: FortiESNAC.exe --register <code>
# Handles "already registered" as success
# Waits up to 120 seconds for registry update
# Verifies registration succeeded
```

#### Improvements Needed:
1. Add standardized script headers (following SCRIPT_HEADER_STANDARD.md)
2. Update to match your toolkit's documentation format
3. Consider making invitation code a configurable parameter (currently hardcoded)
4. Add to appropriate category (e.g., `Windows/Script - FortiClient ZTNA/`)

#### Value Add:
- Solves real-world problem (automated ZTNA registration)
- Complements existing security-focused scripts in toolkit
- Ready for immediate use with minimal modifications

---

### ✅ 2. OneDrive User Configuration - **RECOMMENDED**

**Location:** `OneDriveUserConfig.ps1` (118 lines)

#### Purpose:
Comprehensive user-context OneDrive for Business configuration with Known Folder Move (KFM).

#### Analysis:
- **✅ User context:** Runs in user scope (HKCU registry)
- **✅ Comprehensive:** Configures OneDrive settings, launches client, implements KFM
- **✅ Production ready:** Logging, error handling, wait loops
- **✅ Useful:** Automates OneDrive setup for new users

#### Features:
1. **Registry Configuration:**
   - `DefaultToBusinessFRE = 1`
   - `DisablePersonalSync = 1`
   - `EnableEnterpriseTier = 1`
   - `EnableADAL = 1`

2. **Known Folder Move (KFM):**
   - Desktop → OneDrive
   - Documents → OneDrive (with content copy)
   - Pictures → OneDrive

3. **Auto-start:**
   - Launches OneDrive.exe in hidden mode
   - Waits for Business account to appear
   - Configures folder redirection

#### Improvements Needed:
1. Add standardized header (SYNOPSIS, DESCRIPTION, NOTES)
2. Make organization email domain configurable (currently hardcoded logic)
3. Consider detection script to check if already configured
4. Add to toolkit as: `Windows/Script - Configure OneDrive KFM/`

#### Comparison to Existing:
Your toolkit already has `Windows/Configure - OneDrive (silent sync)/` for device-level config.  
This script is **complementary** - it's for **user-level** setup and KFM configuration.

#### Value Add:
- User-focused OneDrive automation
- Known Folder Move implementation
- Can run as Intune script or Win32 app

---

### ⚠️ 3. OneDrive User Logon - **CONSIDER (Lower Priority)**

**Location:** `OneDriveUserLogon.ps1` (50 lines)

#### Purpose:
Lightweight registry initializer for OneDrive at user logon.

#### Analysis:
- **⚠️ Overlap:** Similar to OneDriveUserConfig.ps1 but less comprehensive
- **✅ Simple:** Just sets required registry keys and launches OneDrive
- **✅ Logon script:** Designed to run at each user logon
- **⚠️ Hardcoded:** Email domain hardcoded (`@cohealth.org.au`)

#### Recommendation:
**Skip this one** - `OneDriveUserConfig.ps1` is more comprehensive and better suited for Intune.  
This appears to be a lightweight logon script for a specific environment.

---

### ❌ 4. AVD Management Scripts - **NOT SUITABLE**

**Location:** Root folder

#### Scripts:
1. `alert-host-drain.ps1` (51 lines) - Email alerts for AVD host drain status
2. `pool-status-label.ps1` (85 lines) - Updates AVD app group labels based on health
3. `start-pool-hosts.ps1` (50 lines) - Auto-starts AVD session hosts

#### Why NOT Suitable:
- **❌ Azure Automation:** These are Azure Automation runbooks, not Intune scripts
- **❌ Different scope:** Manage AVD infrastructure, not endpoints
- **❌ Requires Azure context:** Use `Connect-AzAccount -Identity` (managed identity)
- **❌ Server-side:** Run in Azure, not on client devices
- **❌ Different tooling:** Az.Wvd module, SMTP2GO, etc.

#### Correct Repository:
These belong in an **Azure Automation** or **AVD Management** repository, not Intune-Toolkit.

**Recommendation:** Create separate repo like `AVD-Automation-Runbooks` for these.

---

### ❌ 5. Configuration Files - **NOT SUITABLE**

**Location:** Root folder

#### Files:
- `AVDStartMenu.json` - Start menu layout (AVD-specific)
- `AVDTaskBar.xml` - Taskbar layout (AVD-specific)

#### Why NOT Suitable:
- **❌ AVD-specific:** Part of AVD golden image configuration
- **❌ Not Intune scripts:** Configuration files, not executable scripts
- **❌ Already covered:** Your toolkit has `Windows/Configure - Taskbar/` with taskbar XML

#### Recommendation:
Keep these with AVD infrastructure configuration, not in Intune-Toolkit.

---

### ❌ 6. FSLogix Configuration - **NOT SUITABLE**

**Location:** `FSLogix/`

#### Files:
- `FSLogixRedirections.xml` - FSLogix folder redirection config
- `Screenshot 2025-07-02 123011.png` - Documentation screenshot

#### Why NOT Suitable:
- **❌ AVD-specific:** FSLogix is primarily for AVD/RDS environments
- **❌ Configuration file:** XML config, not executable script
- **❌ Niche use case:** Most Intune users don't use FSLogix

#### Recommendation:
Include in AVD-specific documentation or infrastructure repo.

---

### ❌ 7. Login Auditing - **NOT SUITABLE**

**Location:** `Login Auditing/`

#### Files:
- `Log Login.xml` - Scheduled task XML
- `log-login.bat` - Batch script for login logging

#### Why NOT Suitable:
- **❌ Old technology:** Batch script and scheduled task (legacy approach)
- **❌ Limited value:** Basic login logging (already available via Intune/Entra logs)
- **❌ Not PowerShell:** Batch script doesn't match toolkit's PowerShell focus
- **❌ Better alternatives:** Use Intune compliance policies or Microsoft Sentinel

#### Recommendation:
Not needed - modern logging solutions are better.

---

### ❌ 8. Misc Admin Tools - **NOT SUITABLE**

**Location:** `Misc/`

#### Scripts:
1. `Add-ResourceCalendarPermissions.ps1` - Exchange Online calendar permissions
2. `AVD.ps1` - Likely AVD admin utility
3. `Azure.ps1` - Azure management utility
4. `Azure_CreateDiskSnapshot.ps1` - Azure disk snapshot automation
5. `Azure_ReplaceVMDisk.ps1` - Azure VM disk replacement
6. `GetUsersOceanOU.ps1` - AD user query (organization-specific)

#### Why NOT Suitable:
- **❌ Not endpoint management:** These are admin/infrastructure tools
- **❌ Different scope:** Exchange, Azure infrastructure, AD queries
- **❌ Organization-specific:** Some are hardcoded for specific orgs
- **❌ Not Intune:** Run from admin workstation, not deployed to endpoints

#### Recommendation:
Keep these in a separate **Admin Tools** or **IT Utilities** repository.

---

## Implementation Roadmap

### Phase 1: FortiClient ZTNA (Immediate - High Value)

**Steps:**
1. Create directory: `Windows/Script - FortiClient ZTNA/`
2. Copy files:
   - `Detect-ZTNA.ps1` → `FortiClient-ZTNA_Detection.ps1`
   - `Remediate-ZTNA.ps1` → `FortiClient-ZTNA_Remediation.ps1`
3. Add standardized headers following `SCRIPT_HEADER_STANDARD.md`
4. Make invitation code configurable (parameter or variable at top)
5. Update exit code documentation
6. Test thoroughly
7. Create README.md with:
   - Purpose
   - Prerequisites (FortiClient installed)
   - Configuration instructions (invitation code)
   - Deployment guide (Intune Proactive Remediation)

**Estimated effort:** 1-2 hours

### Phase 2: OneDrive User Configuration (Soon - Medium Value)

**Steps:**
1. Create directory: `Windows/Script - Configure OneDrive KFM (User)/`
2. Copy `OneDriveUserConfig.ps1` → `Configure-OneDrive-KFM_User.ps1`
3. Add standardized header
4. Make email domain/tenant configurable
5. Optionally create detection script to check if already configured
6. Update folder redirection list to be easily customizable
7. Create README.md with:
   - Purpose (User-level OneDrive + KFM setup)
   - Comparison to existing device-level OneDrive config
   - Configuration options
   - Known Folder Move customization
8. Test in user context

**Estimated effort:** 2-3 hours

### Phase 3: Documentation & Organization (Optional)

**Steps:**
1. Update main `Windows/README.md` with new scripts
2. Consider creating category for "User Context Scripts" vs "System Context Scripts"
3. Add cross-references between device-level and user-level OneDrive configs
4. Update `DETECTION_STRATEGY_GUIDE.md` with FortiClient example

**Estimated effort:** 1 hour

---

## Scripts to Archive/Organize Separately

### Azure AVD Automation Repository (Recommended)
Create new repository: `AVD-Automation-Runbooks`

**Contents:**
- `alert-host-drain.ps1`
- `pool-status-label.ps1`
- `start-pool-hosts.ps1`
- `AVDStartMenu.json`
- `AVDTaskBar.xml`
- `FSLogix/` folder

**Purpose:** Azure Automation runbooks for AVD management

### Admin Utilities Repository (Optional)
Create repository: `IT-Admin-Tools`

**Contents:**
- `Misc/` folder scripts
- Other ad-hoc admin utilities

**Purpose:** IT admin tools and one-off scripts

---

## Summary Table

| Script/Folder | Type | Intune-Toolkit? | Reasoning | Alternative |
|---------------|------|-----------------|-----------|-------------|
| **FortiZTNA/** | Proactive Remediation | ✅ **YES** | Perfect Intune fit | - |
| **OneDriveUserConfig.ps1** | User Script | ✅ **YES** | Valuable user automation | - |
| **OneDriveUserLogon.ps1** | Logon Script | ⚠️ Skip | Overlaps with above | Use OneDriveUserConfig instead |
| **alert-host-drain.ps1** | Azure Runbook | ❌ NO | AVD infrastructure | AVD-Automation-Runbooks repo |
| **pool-status-label.ps1** | Azure Runbook | ❌ NO | AVD infrastructure | AVD-Automation-Runbooks repo |
| **start-pool-hosts.ps1** | Azure Runbook | ❌ NO | AVD infrastructure | AVD-Automation-Runbooks repo |
| **AVDStartMenu.json** | Config File | ❌ NO | AVD-specific config | AVD infrastructure docs |
| **AVDTaskBar.xml** | Config File | ❌ NO | AVD-specific config | AVD infrastructure docs |
| **FSLogix/** | Config Files | ❌ NO | AVD/FSLogix specific | AVD infrastructure docs |
| **Login Auditing/** | Legacy Scripts | ❌ NO | Outdated approach | Use Intune/Sentinel logging |
| **Misc/** | Admin Tools | ❌ NO | Not endpoint mgmt | IT-Admin-Tools repo |

---

## Recommendations

### Immediate Actions:
1. ✅ **Add FortiClient ZTNA scripts** to Intune-Toolkit (high value, production ready)
2. ✅ **Add OneDrive User Config** to Intune-Toolkit (valuable user automation)

### Future Organization:
3. 📁 **Create AVD-Automation-Runbooks repo** for AVD management scripts
4. 📁 **Consider IT-Admin-Tools repo** for misc admin utilities
5. 🗑️ **Archive Login Auditing** (outdated, better alternatives exist)

### Quality Improvements:
6. 📝 Apply standardized headers to new scripts
7. 🧪 Test scripts thoroughly before adding
8. 📚 Create comprehensive READMEs for new additions
9. 🔗 Cross-reference related scripts in documentation

---

## Files Ready for Migration

### Priority 1: FortiClient ZTNA
```
Source: /Scripts/FortiZTNA/
Target: /Intune-Toolkit/Windows/Script - FortiClient ZTNA/
Files:
  - Detect-ZTNA.ps1 → FortiClient-ZTNA_Detection.ps1
  - Remediate-ZTNA.ps1 → FortiClient-ZTNA_Remediation.ps1
```

### Priority 2: OneDrive User Config
```
Source: /Scripts/OneDriveUserConfig.ps1
Target: /Intune-Toolkit/Windows/Script - Configure OneDrive KFM (User)/
Files:
  - OneDriveUserConfig.ps1 → Configure-OneDrive-KFM_User.ps1
```

---

## Conclusion

Out of ~15+ files analyzed:
- **2 scripts are excellent additions** to Intune-Toolkit (FortiClient ZTNA pair)
- **1 script is a good addition** (OneDrive User Config)
- **8+ scripts belong in different repositories** (AVD automation, admin tools)
- **3+ files can be archived** (duplicates, outdated, AVD configs)

The FortiClient ZTNA scripts are the **highest value addition** - they're production-ready, solve a real problem, and perfectly fit the Intune Proactive Remediation model.

**Next Step:** Would you like me to migrate the FortiClient ZTNA scripts first?
