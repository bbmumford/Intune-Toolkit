# OneDrive for Business - User-Level Known Folder Move Configuration

## Overview

This script configures OneDrive for Business in **user context** and optionally redirects known folders (Desktop, Documents, Pictures) to OneDrive using Known Folder Move (KFM). This is a user-level configuration that complements device-level OneDrive policies.

### Purpose

- Configure per-user OneDrive for Business registry settings
- Automatically launch and initialize OneDrive client
- Redirect Windows known folders to OneDrive (Desktop, Documents, Pictures)
- Optionally migrate existing folder contents to OneDrive
- Provide comprehensive logging for troubleshooting

### Key Features

- ✅ **User Context Execution** - Runs as the logged-in user (required for KFM)
- ✅ **Known Folder Move API** - Uses `SHSetKnownFolderPath` for reliable folder redirection
- ✅ **Configurable Folder List** - Easy customization of which folders to redirect
- ✅ **Content Migration** - Optional copy of existing files to OneDrive
- ✅ **OneDrive Business Enforcement** - Disables personal OneDrive, enforces business account
- ✅ **Automatic Retry Logic** - Waits up to 5 minutes for OneDrive initialization
- ✅ **Comprehensive Logging** - Full transcript logs in user AppData

## Files

| File Name | Run Context | Description |
|-----------|-------------|-------------|
| `Configure-OneDrive-KFM_User.ps1` | **User** | Main script - configures OneDrive and performs Known Folder Move |
| `README.md` | N/A | This documentation file |

## How It Differs From Device-Level OneDrive Configuration

This user-level script is designed to work **alongside** device-level OneDrive policies (GPO or Intune Configuration Profiles). Here's the comparison:

### Device-Level OneDrive Configuration (in this repo)
- **Path**: `Windows/Configure - OneDrive (silent sync)/`
- **Context**: SYSTEM or Device
- **Purpose**: 
  - Silent account configuration
  - Tenant restrictions
  - SharePoint site auto-mount
  - Files On-Demand policies
- **Typical deployment**: Intune Configuration Profile or Device-level script

### User-Level OneDrive Configuration (this folder)
- **Path**: `Windows/Script - Configure OneDrive KFM (User)/`
- **Context**: User
- **Purpose**:
  - Known Folder Move execution
  - User-specific registry settings
  - Per-user folder redirection
  - Content migration
- **Typical deployment**: Intune User script or logon script

**⚠️ Important**: Both configurations can coexist. Device-level policies control the OneDrive client behavior, while this user-level script handles folder redirection which requires user context.

## Prerequisites

- ✅ **Windows 10/11** (1809 or later recommended)
- ✅ **OneDrive sync client installed** (usually pre-installed)
- ✅ **OneDrive for Business license** assigned to user
- ✅ **PowerShell 5.0 or higher** (included in Windows 10/11)
- ✅ **Network connectivity** to Microsoft 365 services
- ✅ **User context execution** (will fail if run as SYSTEM)

## Configuration

### Step 1: Customize Folder Redirection Settings

Open `Configure-OneDrive-KFM_User.ps1` and modify the configuration section:

```powershell
# Set to $true to redirect known folders to OneDrive for Business
$redirectFoldersToOneDriveForBusiness = $True

# Configure which folders to redirect
$listOfFoldersToRedirectToOneDriveForBusiness = @(
    @{ 
        knownFolderInternalName    = "Desktop"
        knownFolderInternalIdentifier = "Desktop"
        desiredSubFolderNameInOnedrive = "Desktop"
        copyContents = $false 
    },
    @{ 
        knownFolderInternalName    = "MyDocuments"
        knownFolderInternalIdentifier = "Documents"
        desiredSubFolderNameInOnedrive = "My Documents"
        copyContents = $true  
    },
    @{ 
        knownFolderInternalName    = "MyPictures"
        knownFolderInternalIdentifier = "Pictures"
        desiredSubFolderNameInOnedrive = "My Pictures"
        copyContents = $false 
    }
)
```

#### Folder Configuration Options

Each folder entry has four properties:

| Property | Purpose | Example Values |
|----------|---------|----------------|
| `knownFolderInternalName` | Friendly name (for logging) | "Desktop", "MyDocuments", "MyPictures" |
| `knownFolderInternalIdentifier` | System identifier | "Desktop", "Documents", "Pictures" |
| `desiredSubFolderNameInOnedrive` | Target folder name in OneDrive | "Desktop", "My Documents", "My Pictures" |
| `copyContents` | Copy existing files to OneDrive | `$true` or `$false` |

**⚠️ Copy Contents Warning**: 
- `$true` = Copies ALL existing files from local folder to OneDrive (can take time for large folders)
- `$false` = Folder redirects immediately without copying existing content (files stay in old location)

### Step 2: Adjust Wait Times (Optional)

If OneDrive takes longer to initialize in your environment:

```powershell
# Maximum wait time for OneDrive Business account detection
$maxWaitIterations = 20        # Number of attempts
$waitIntervalSeconds = 15      # Seconds between attempts
# Total wait time = 20 x 15 = 300 seconds (5 minutes)
```

**Recommendations**:
- **Fast networks**: 10 iterations × 10 seconds = 100 seconds
- **Standard networks**: 20 iterations × 15 seconds = 300 seconds (default)
- **Slow/VPN networks**: 30 iterations × 15 seconds = 450 seconds

## Deployment Options

### Option 1: Intune PowerShell Script (Recommended)

1. **Navigate to Intune portal** → Devices → Scripts → Windows → Add → Windows 10 and later
2. **Configure script settings**:
   - Name: `OneDrive KFM - User Configuration`
   - Description: `Configures OneDrive for Business and redirects known folders to OneDrive`
   - Script location: Upload `Configure-OneDrive-KFM_User.ps1`
   - **Run this script using the logged on credentials**: **Yes** ✅ (CRITICAL)
   - Run script in 64-bit PowerShell: Yes
3. **Assign to groups**: Target user groups (not device groups)
4. **Review and save**

**✅ Advantages**:
- Native Intune deployment
- User context guaranteed
- Automatic retry on failure
- Built-in reporting

### Option 2: Win32 App Package

If you need more control over execution timing:

1. **Package the script** using [Microsoft Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool):
   ```powershell
   IntuneWinAppUtil.exe -c "C:\Source" -s "Configure-OneDrive-KFM_User.ps1" -o "C:\Output"
   ```

2. **Create Win32 app in Intune**:
   - Install command: `powershell.exe -ExecutionPolicy Bypass -File "Configure-OneDrive-KFM_User.ps1"`
   - Uninstall command: `cmd.exe /c`
   - Install behavior: **User** ✅
   - Detection rule: Custom script or registry (see Detection Rules section)

3. **Assign to users** with required or available intent

**✅ Advantages**:
- More deployment options (required/available)
- Custom detection rules
- Supersedence support

### Option 3: Logon Script (GPO)

For hybrid environments with Active Directory:

1. **Copy script to network share**: `\\domain.com\SYSVOL\domain.com\scripts\`
2. **Create GPO**:
   - User Configuration → Policies → Windows Settings → Scripts → Logon
   - Add script: `\\domain.com\SYSVOL\domain.com\scripts\Configure-OneDrive-KFM_User.ps1`
   - PowerShell Scripts (recommended) or Logon Scripts
3. **Link GPO to OU** containing user accounts

**⚠️ Considerations**:
- Requires network access to SYSVOL
- Runs at every logon unless you add your own detection logic
- Less reporting than Intune

## Detection Rules (for Win32 App Deployment)

If deploying as a Win32 app, use one of these detection methods:

### Option 1: Registry Detection (Recommended)

**Detection type**: Registry  
**Key path**: `HKEY_CURRENT_USER\Software\Microsoft\OneDrive`  
**Value name**: `EnableEnterpriseTier`  
**Detection method**: Integer comparison  
**Operator**: Equals  
**Value**: 1  

### Option 2: Custom Script Detection

Create `Detect-OneDriveKFM.ps1`:

```powershell
# Check if OneDrive settings are configured
$oneDriveReg = 'HKCU:\Software\Microsoft\OneDrive'
$requiredSettings = @('DefaultToBusinessFRE', 'DisablePersonalSync', 'EnableEnterpriseTier', 'EnableADAL')

$allConfigured = $true
foreach ($setting in $requiredSettings) {
    $value = Get-ItemProperty -Path $oneDriveReg -Name $setting -ErrorAction SilentlyContinue
    if ($value.$setting -ne 1) {
        $allConfigured = $false
        break
    }
}

# Check if at least one known folder is redirected to OneDrive
$desktopPath = [Environment]::GetFolderPath('Desktop')
$oneDriveDetected = $desktopPath -match 'OneDrive'

if ($allConfigured -and $oneDriveDetected) {
    Write-Output "OneDrive KFM configured"
    Exit 0
} else {
    Exit 1
}
```

**Detection type**: Custom script  
**Script**: Upload `Detect-OneDriveKFM.ps1`  
**Run script as 32-bit**: No  
**Enforce script signature check**: No  

## How It Works

### Step 1: Registry Configuration
The script sets these **HKCU** registry values:

```
HKCU:\Software\Microsoft\OneDrive
├── DefaultToBusinessFRE = 1      (Prefer Business account)
├── DisablePersonalSync = 1       (Block personal OneDrive)
├── EnableEnterpriseTier = 1      (Enable enterprise features)
└── EnableADAL = 1                (Azure AD auth)
```

### Step 2: OneDrive Launch
- Locates OneDrive.exe (from registry or default path)
- Starts OneDrive client in hidden mode
- No user interaction required

### Step 3: Business Account Detection
- Monitors registry: `HKCU:\Software\Microsoft\OneDrive\Accounts\Business`
- Waits for `UserFolder` value (OneDrive sync path)
- Validates folder exists on disk
- Retries every 15 seconds for up to 5 minutes

### Step 4: Known Folder Move Execution
If enabled (`$redirectFoldersToOneDriveForBusiness = $True`):

1. **Load Windows API**: Import `SHSetKnownFolderPath` from shell32.dll
2. **Process each folder**:
   - Create target folder in OneDrive (e.g., `C:\Users\John\OneDrive - Contoso\Desktop`)
   - Call `SHSetKnownFolderPath` with folder GUID
   - If `copyContents = $true`, copy existing files
   - Hide old folder location
3. **Update Explorer shell**: Windows Explorer automatically reflects changes

**GUID Reference**:
- Desktop: `B4BFCC3A-DB2C-424C-B029-7FE99A87C641`
- Documents: `FDD39AD0-238F-46AF-ADB4-6C85480369C7`, `f42ee2d3-909f-4907-8871-4c22fc0bf756`
- Pictures: `33E28130-4E1E-4676-835A-98395C3BC3BB`, `0ddd015d-b06c-45d5-8c4c-f59713854639`

## Verification

### Method 1: Check Windows Explorer
1. Open **File Explorer**
2. Expand **This PC** or **Quick Access**
3. Verify known folders show OneDrive icon and path:
   - Desktop → `OneDrive - YourCompany\Desktop`
   - Documents → `OneDrive - YourCompany\My Documents`
   - Pictures → `OneDrive - YourCompany\My Pictures`

### Method 2: Registry Verification

```powershell
# Check OneDrive settings
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\OneDrive' | Select-Object DefaultToBusinessFRE, DisablePersonalSync, EnableEnterpriseTier, EnableADAL

# Check OneDrive Business account
Get-ChildItem 'HKCU:\Software\Microsoft\OneDrive\Accounts\Business' | ForEach-Object {
    Get-ItemProperty $_.PSPath | Select-Object UserFolder, UserEmail
}

# Check known folder redirection (Desktop example)
$desktopPath = [Environment]::GetFolderPath('Desktop')
Write-Output "Desktop location: $desktopPath"
```

**Expected Results**:
- All OneDrive settings = 1
- UserFolder points to OneDrive sync location
- Desktop/Documents/Pictures paths contain "OneDrive"

### Method 3: Log File Review

```powershell
# View most recent log
$logPath = Join-Path $Env:LOCALAPPDATA 'Lieben.nu\Logs\OneDriveUserConfig.log'
Get-Content $logPath -Tail 50
```

**Success indicators** in log:
```
✔ HKCU OneDrive settings applied successfully
✔ Launched OneDrive.exe: C:\Users\...\OneDrive.exe
✔ OneDrive Business folder detected: C:\Users\...\OneDrive - Contoso
✔ Successfully redirected Desktop → C:\Users\...\OneDrive - Contoso\Desktop
```

### Method 4: OneDrive Client Status
1. Right-click OneDrive icon in system tray
2. Select **Settings** → **Account** tab
3. Verify:
   - Business account is listed
   - "Choose folders" shows configured folders (Desktop, Documents, Pictures)

### Method 5: Intune Reporting

**For PowerShell Script deployment**:
- Navigate to: Devices → Scripts → `OneDrive KFM - User Configuration` → Device status
- Check for successful runs (exit code 0)

**For Win32 App deployment**:
- Navigate to: Apps → Windows apps → `OneDrive KFM - User Configuration` → Device install status
- Verify "Installed" status

## Troubleshooting

### Issue 1: "Could not detect OneDrive Business folder"

**Symptoms**:
- Script exits with code 1
- Log shows: `✖ Could not detect OneDrive Business folder after 300 seconds`

**Possible Causes & Solutions**:

| Cause | Solution |
|-------|----------|
| User not signed into OneDrive | Manually sign in: OneDrive icon → Sign in |
| No OneDrive for Business license | Assign Microsoft 365 license in admin portal |
| Network connectivity issues | Check firewall, proxy settings for *.onedrive.com |
| OneDrive not running | Increase `$maxWaitIterations` or manually start OneDrive |
| Personal OneDrive blocking Business | Unlink personal account: OneDrive Settings → Account → Unlink this PC |

**Manual check**:
```powershell
# Check if OneDrive Business registry exists
Test-Path 'HKCU:\Software\Microsoft\OneDrive\Accounts\Business'

# If false, OneDrive hasn't authenticated yet
# If true, check UserFolder value:
Get-ItemProperty 'HKCU:\Software\Microsoft\OneDrive\Accounts\Business\Business1' -Name UserFolder
```

### Issue 2: "Failed to redirect folder"

**Symptoms**:
- Log shows: `✖ Failed to redirect Documents: ...`
- Folder still points to local path

**Possible Causes & Solutions**:

| Cause | Solution |
|-------|----------|
| Folder in use by application | Close all File Explorer windows and apps accessing the folder |
| Insufficient permissions | Run as actual user (not SYSTEM), verify user owns folder |
| OneDrive path not ready | Verify OneDrive sync is active and folder exists in OneDrive |
| Files locked/open | Close all documents, reboot and retry |
| Group Policy conflict | Check GPO: `User Configuration → Administrative Templates → Windows Components → OneDrive` |

**Manual test**:
```powershell
# Try to set Desktop manually
$targetPath = "C:\Users\YourName\OneDrive - Contoso\Desktop"
New-Item -Path $targetPath -ItemType Directory -Force

Add-Type -MemberDefinition @'
[DllImport("shell32.dll")]
public extern static int SHSetKnownFolderPath(ref Guid folderId, uint flags, System.IntPtr token, [MarshalAs(UnmanagedType.LPWStr)] string path);
'@ -Name 'KnownFolders' -Namespace 'Interop' -PassThru

$guid = [Guid]'B4BFCC3A-DB2C-424C-B029-7FE99A87C641'
[Interop.KnownFolders]::SHSetKnownFolderPath([ref]$guid, 0, [IntPtr]::Zero, $targetPath)
```

### Issue 3: Script runs but folders not redirected

**Symptoms**:
- Script reports success
- Folders still point to local paths (C:\Users\Username\Desktop)

**Possible Causes & Solutions**:

| Cause | Solution |
|-------|----------|
| `$redirectFoldersToOneDriveForBusiness = $False` | Change to `$True` in script configuration |
| Script ran as SYSTEM | Verify deployment runs in **user context** |
| OneDrive sync paused | Resume sync: OneDrive icon → Resume syncing |
| Shell didn't refresh | Log off and log back in |

### Issue 4: Files not copied to OneDrive

**Symptoms**:
- Folders redirected successfully
- Existing files missing from OneDrive location

**Possible Causes & Solutions**:

| Cause | Solution |
|-------|----------|
| `copyContents = $false` for that folder | Change to `$true` in folder configuration |
| Copy failed silently | Check log for warnings, manually copy files |
| Large files timing out | Increase script timeout or manually copy large files |
| Permissions on source files | Run as user who owns the files |

**Manual copy**:
```powershell
# Example: Copy Desktop contents manually
$source = "C:\Users\YourName\Desktop"
$target = "C:\Users\YourName\OneDrive - Contoso\Desktop"
Copy-Item -Path "$source\*" -Destination $target -Recurse -Force
```

### Issue 5: Script runs on every logon

**Symptoms**:
- Script executes repeatedly
- No detection logic to skip if already configured

**Solutions**:

**For Intune PowerShell Scripts**:
- Intune handles this automatically - script won't re-run if successful
- If needed, add detection at script start:
  ```powershell
  # Add at beginning of script (after param block)
  $alreadyConfigured = (Get-ItemProperty 'HKCU:\Software\Microsoft\OneDrive' -Name EnableEnterpriseTier -ErrorAction SilentlyContinue).EnableEnterpriseTier -eq 1
  if ($alreadyConfigured) {
      Write-Output "Already configured, skipping"
      Exit 0
  }
  ```

**For GPO Logon Scripts**:
- Wrap entire script in detection check (see above)
- Or use Intune instead (handles this natively)

### Issue 6: OneDrive.exe not found

**Symptoms**:
- Script exits with: `✖ OneDrive.exe not found at: ...`

**Solutions**:

1. **Install OneDrive client**:
   - Download: [OneDrive for Windows](https://www.microsoft.com/en-us/microsoft-365/onedrive/download)
   - Or deploy via Intune: `Windows/Script - Install OneDrive/` (if available)

2. **Check installation paths**:
   ```powershell
   # Common locations
   Test-Path "$Env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
   Test-Path "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
   Test-Path "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe"
   ```

3. **Update registry trigger** (if custom install location):
   ```powershell
   New-ItemProperty -Path 'HKCU:\Software\Microsoft\OneDrive' -Name 'OneDriveTrigger' -Value "C:\CustomPath\OneDrive.exe" -Force
   ```

## Advanced Configuration

### Custom Folder Redirection

You can redirect additional folders by adding entries to the configuration array:

#### Example: Redirect Music and Videos

```powershell
$listOfFoldersToRedirectToOneDriveForBusiness = @(
    @{ 
        knownFolderInternalName    = "Desktop"
        knownFolderInternalIdentifier = "Desktop"
        desiredSubFolderNameInOnedrive = "Desktop"
        copyContents = $false 
    },
    @{ 
        knownFolderInternalName    = "MyMusic"
        knownFolderInternalIdentifier = "Music"
        desiredSubFolderNameInOnedrive = "Music"
        copyContents = $true 
    },
    @{ 
        knownFolderInternalName    = "MyVideos"
        knownFolderInternalIdentifier = "Videos"
        desiredSubFolderNameInOnedrive = "Videos"
        copyContents = $false 
    }
)
```

**Additional GUIDs** (add to `$KnownFolderGuids` hashtable):

```powershell
$KnownFolderGuids = @{
    Desktop   = @([Guid]'B4BFCC3A-DB2C-424C-B029-7FE99A87C641')
    Documents = @([Guid]'FDD39AD0-238F-46AF-ADB4-6C85480369C7', [Guid]'f42ee2d3-909f-4907-8871-4c22fc0bf756')
    Pictures  = @([Guid]'33E28130-4E1E-4676-835A-98395C3BC3BB', [Guid]'0ddd015d-b06c-45d5-8c4c-f59713854639')
    Music     = @([Guid]'4BD8D571-6D19-48D3-BE97-422220080E43', [Guid]'a0c69a99-21c8-4671-8703-7934162fcf1d')
    Videos    = @([Guid]'18989B1D-99B5-455B-841C-AB7C74E4DDFC', [Guid]'35286a68-3c57-41a1-bbb1-0eae73d76c95')
}
```

### Exclude Folders from Redirection

To disable redirection for specific folders, simply remove them from the array:

```powershell
# Only redirect Documents
$listOfFoldersToRedirectToOneDriveForBusiness = @(
    @{ 
        knownFolderInternalName    = "MyDocuments"
        knownFolderInternalIdentifier = "Documents"
        desiredSubFolderNameInOnedrive = "My Documents"
        copyContents = $true 
    }
)
```

### Change OneDrive Subfolder Names

Customize the folder names in OneDrive:

```powershell
# Redirect Desktop to "Work Desktop" folder in OneDrive
@{ 
    knownFolderInternalName    = "Desktop"
    knownFolderInternalIdentifier = "Desktop"
    desiredSubFolderNameInOnedrive = "Work Desktop"  # ← Custom name
    copyContents = $false 
}
```

**Result**: Desktop redirects to `C:\Users\Username\OneDrive - Company\Work Desktop`

## Security Considerations

### Permissions
- ✅ Script runs as **user**, not SYSTEM (required for Known Folder Move)
- ✅ Only affects current user's profile
- ✅ User must have write access to OneDrive folder
- ✅ No elevation required

### Data Protection
- ✅ Content copying preserves file attributes
- ✅ Original files remain in old location (hidden) unless manually deleted
- ✅ OneDrive Files On-Demand protects local disk space
- ✅ Supports BitLocker encrypted drives

### Network Security
- ✅ All communication with OneDrive uses TLS 1.2+
- ✅ Azure AD authentication (ADAL enabled)
- ✅ Respects Conditional Access policies
- ⚠️ Requires outbound access to: `*.onedrive.com`, `*.sharepoint.com`, `login.microsoftonline.com`

### Logging
- ⚠️ Logs stored in user AppData: `%LOCALAPPDATA%\Lieben.nu\Logs\OneDriveUserConfig.log`
- ⚠️ Logs contain folder paths and user context
- ✅ No credentials or sensitive data logged

## Best Practices

1. **Test before production deployment**
   - Deploy to pilot group first
   - Verify folder redirection works as expected
   - Check content migration if `copyContents = $true`

2. **Use device-level policies alongside this script**
   - Deploy device config for OneDrive settings (silent account config, Files On-Demand)
   - Use this script specifically for Known Folder Move
   - Avoid conflicts between user and device policies

3. **Monitor log files**
   - Include log collection in troubleshooting procedures
   - Consider centralizing logs with Intune diagnostics or log analytics

4. **Communication to users**
   - Inform users about folder redirection before deployment
   - Explain OneDrive sync behavior (Files On-Demand)
   - Provide training materials for OneDrive usage

5. **Handle large folders carefully**
   - For users with large Desktop/Documents folders, consider `copyContents = $false`
   - Educate users to manually move important files
   - Monitor OneDrive sync status post-deployment

6. **Combine with OneDrive policies**
   - Enable Files On-Demand
   - Configure Silent Account Configuration (device-level)
   - Set appropriate sync restrictions (file type exclusions)

## Related Documentation

- [Main Repository Documentation](../../README.md)
- [Device-Level OneDrive Configuration](../Configure%20-%20OneDrive%20(silent%20sync)/)
- [OneDrive Admin Guide - Known Folder Move](https://learn.microsoft.com/en-us/onedrive/redirect-known-folders)
- [Intune PowerShell Scripts](https://learn.microsoft.com/en-us/mem/intune/apps/intune-management-extension)
- [OneDrive Files On-Demand](https://support.microsoft.com/en-us/office/save-disk-space-with-onedrive-files-on-demand-0e6860d3-d9f3-4971-b321-7092438fb38e)

## Credits

Original script concept by **Lieben.nu** - Adapted and enhanced for the Intune-Toolkit repository with standardized headers, improved error handling, and comprehensive documentation.

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section above
2. Review log file: `%LOCALAPPDATA%\Lieben.nu\Logs\OneDriveUserConfig.log`
3. Open an issue on the [GitHub repository](https://github.com/bbmumford/Intune-Toolkit/issues)
4. Consult [Microsoft OneDrive documentation](https://learn.microsoft.com/en-us/onedrive/)
