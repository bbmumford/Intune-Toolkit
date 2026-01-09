<#
.SYNOPSIS
    Configures OneDrive for Business per-user settings and redirects known folders to OneDrive.

.DESCRIPTION
    This script runs in user context to configure OneDrive for Business client settings and
    optionally redirect known folders (Desktop, Documents, Pictures) to OneDrive using Known
    Folder Move (KFM). 
    
    The script performs the following actions:
    1. Sets per-user registry settings to enforce OneDrive for Business
    2. Launches the OneDrive client
    3. Waits for OneDrive Business account detection
    4. Redirects configured known folders to OneDrive subfolders
    5. Optionally copies existing content to the new locations
    
    This is a user-level configuration script that complements device-level OneDrive policies.
    It uses the SHSetKnownFolderPath API to perform folder redirection, which is more reliable
    than simple registry changes.

.NOTES
    File Name      : Configure-OneDrive-KFM_User.ps1
    Author         : Based on original work by Lieben.nu, adapted for Intune-Toolkit
    Prerequisite   : OneDrive client must be installed
                     Windows 10/11
                     PowerShell 5.0 or higher
    Version        : 1.0
    Date           : 2025-01-01
    
    Requirements:
    - Runs in USER context (SYSTEM context will fail)
    - OneDrive sync client installed
    - User must have OneDrive for Business license
    - Network connectivity to authenticate to Microsoft 365
    
    Exit Codes:
    - 0: Success (OneDrive configured and folders redirected if enabled)
    - 1: Failure (OneDrive Business folder not detected, or critical error)
    
    Deployment Notes:
    - Deploy via Intune as a PowerShell script with user context
    - Or package as Win32 app with SYSTEM install but user execution
    - Script creates logs in user's AppData\Local\Lieben.nu\Logs\
    - Wait time for OneDrive detection: up to 5 minutes (20 x 15 seconds)

.LINK
    https://github.com/bbmumford/Intune-Toolkit

.EXAMPLE
    .\Configure-OneDrive-KFM_User.ps1
    
    Runs with default settings: redirects Desktop, Documents (with copy), and Pictures to OneDrive.
#>

# ============================================================================
# CONFIGURATION SECTION
# ============================================================================
# Customize these values before deployment

# --- OneDrive Business Account Settings ---
# Set to $true to redirect known folders to OneDrive for Business
$redirectFoldersToOneDriveForBusiness = $True

# Configure which folders to redirect to OneDrive
# - knownFolderInternalName: Internal reference name
# - knownFolderInternalIdentifier: System identifier (Desktop, Documents, Pictures)
# - desiredSubFolderNameInOnedrive: Target folder name in OneDrive
# - copyContents: $true to copy existing files, $false to start fresh
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

# --- Wait Settings ---
# Maximum wait time for OneDrive Business account detection
$maxWaitIterations = 20        # Number of attempts
$waitIntervalSeconds = 15      # Seconds between attempts
# Total wait time = 20 x 15 = 300 seconds (5 minutes)

# ============================================================================
# LOGGING SETUP
# ============================================================================

$userLogFolder = Join-Path $Env:LOCALAPPDATA 'Intune\Logs'
if (-not (Test-Path $userLogFolder)) {
    New-Item -Path $userLogFolder -ItemType Directory -Force | Out-Null
}
$logFile = Join-Path $userLogFolder 'OneDriveUserConfig.log'
Start-Transcript -Path $logFile -Force

Write-Output "========================================="
Write-Output "OneDrive User Configuration Script v1.0"
Write-Output "========================================="
Write-Output "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output ""

# ============================================================================
# STEP 1: CONFIGURE PER-USER REGISTRY SETTINGS
# ============================================================================

Write-Output "[1/4] Configuring per-user OneDrive registry settings..."

Try {
    # Ensure the OneDrive registry key exists
    $oneDriveRegPath = 'HKCU:\Software\Microsoft\OneDrive'
    if (-not (Test-Path $oneDriveRegPath)) {
        New-Item -Path $oneDriveRegPath -Force | Out-Null
    }
    
    # Configure OneDrive to prefer Business account
    New-ItemProperty -Path $oneDriveRegPath -Name 'DefaultToBusinessFRE' -Value 1 -PropertyType DWORD -Force | Out-Null
    Write-Output "  ✔ DefaultToBusinessFRE = 1"
    
    # Disable personal OneDrive sync
    New-ItemProperty -Path $oneDriveRegPath -Name 'DisablePersonalSync' -Value 1 -PropertyType DWORD -Force | Out-Null
    Write-Output "  ✔ DisablePersonalSync = 1"
    
    # Enable Enterprise tier features
    New-ItemProperty -Path $oneDriveRegPath -Name 'EnableEnterpriseTier' -Value 1 -PropertyType DWORD -Force | Out-Null
    Write-Output "  ✔ EnableEnterpriseTier = 1"
    
    # Enable ADAL (Azure Active Directory Authentication Library)
    New-ItemProperty -Path $oneDriveRegPath -Name 'EnableADAL' -Value 1 -PropertyType DWORD -Force | Out-Null
    Write-Output "  ✔ EnableADAL = 1"
    
    Write-Output "✔ HKCU OneDrive settings applied successfully"
    Write-Output ""
} Catch {
    Write-Error "✖ Failed to apply HKCU OneDrive settings: $_"
    Write-Output ""
}

# ============================================================================
# STEP 2: LAUNCH ONEDRIVE CLIENT
# ============================================================================

Write-Output "[2/4] Launching OneDrive client..."

Try {
    # Try to get OneDrive path from registry first
    $odExe = $null
    Try {
        $odExe = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\OneDrive' -Name 'OneDriveTrigger' -ErrorAction Stop).OneDriveTrigger
    } Catch {
        # Fallback to default location
        $odExe = Join-Path $Env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe'
    }
    
    if (-not (Test-Path $odExe)) {
        Write-Error "✖ OneDrive.exe not found at: $odExe"
        Write-Output "Please ensure OneDrive client is installed."
        Stop-Transcript
        Exit 1
    }
    
    # Launch OneDrive in hidden mode
    Start-Process -FilePath $odExe -WindowStyle Hidden
    Write-Output "✔ Launched OneDrive.exe: $odExe"
    Write-Output ""
} Catch {
    Write-Error "✖ Failed to launch OneDrive: $_"
    Stop-Transcript
    Exit 1
}

# ============================================================================
# STEP 3: WAIT FOR ONEDRIVE BUSINESS ACCOUNT DETECTION
# ============================================================================

Write-Output "[3/4] Waiting for OneDrive Business account detection..."
Write-Output "  Maximum wait time: $($maxWaitIterations * $waitIntervalSeconds) seconds"

$rootKey = 'HKCU:\Software\Microsoft\OneDrive\Accounts\Business'
$userFolder = $null

for ($i = 1; $i -le $maxWaitIterations; $i++) {
    Write-Output "  Attempt $i of $maxWaitIterations..."
    
    Start-Sleep -Seconds $waitIntervalSeconds
    
    # Check if Business account exists
    if (Test-Path $rootKey) {
        $businessAccounts = Get-ChildItem $rootKey -ErrorAction SilentlyContinue
        
        if ($businessAccounts) {
            $firstAccount = $businessAccounts | Select-Object -First 1
            $candidatePath = (Get-ItemProperty "$rootKey\$($firstAccount.PSChildName)" -Name 'UserFolder' -ErrorAction SilentlyContinue).UserFolder
            
            if ($candidatePath -and (Test-Path $candidatePath)) {
                $userFolder = $candidatePath
                Write-Output "  ✔ OneDrive Business folder detected: $userFolder"
                Write-Output "  ✔ Account: $($firstAccount.PSChildName)"
                break
            }
        }
    }
}

if (-not $userFolder) {
    Write-Error "✖ Could not detect OneDrive Business folder after $($maxWaitIterations * $waitIntervalSeconds) seconds"
    Write-Output "Possible reasons:"
    Write-Output "  - User not logged in to OneDrive Business"
    Write-Output "  - Network connectivity issues"
    Write-Output "  - OneDrive Business not licensed for this user"
    Write-Output "  - OneDrive client not running or responding"
    Stop-Transcript
    Exit 1
}

Write-Output ""

# ============================================================================
# STEP 4: REDIRECT KNOWN FOLDERS TO ONEDRIVE (OPTIONAL)
# ============================================================================

if ($redirectFoldersToOneDriveForBusiness) {
    Write-Output "[4/4] Configuring Known Folder Move to OneDrive..."
    
    # Add P/Invoke signature for SHSetKnownFolderPath API
    Try {
        Add-Type -MemberDefinition @'
[DllImport("shell32.dll")]
public extern static int SHSetKnownFolderPath(ref Guid folderId, uint flags, System.IntPtr token, [MarshalAs(UnmanagedType.LPWStr)] string path);
'@ -Name 'KnownFolders' -Namespace 'Interop' -PassThru | Out-Null
    } Catch {
        # Type already loaded, safe to ignore
    }
    
    # GUID mappings for known folders
    # Each folder may have multiple GUIDs for different contexts
    $KnownFolderGuids = @{
        Desktop   = @([Guid]'B4BFCC3A-DB2C-424C-B029-7FE99A87C641')
        Documents = @([Guid]'FDD39AD0-238F-46AF-ADB4-6C85480369C7', [Guid]'f42ee2d3-909f-4907-8871-4c22fc0bf756')
        Pictures  = @([Guid]'33E28130-4E1E-4676-835A-98395C3BC3BB', [Guid]'0ddd015d-b06c-45d5-8c4c-f59713854639')
    }
    
    # Helper function to redirect a known folder
    Function Redirect-Folder {
        Param(
            [string]$KnownFolderIdentifier,
            [string]$TargetPath,
            [bool]$CopyContents
        )
        
        # Create target folder if it doesn't exist
        if (-not (Test-Path $TargetPath)) {
            New-Item -Path $TargetPath -ItemType Directory -Force | Out-Null
        }
        
        # Set the known folder path using Windows API
        ForEach ($guid in $KnownFolderGuids[$KnownFolderIdentifier]) {
            $result = [Interop.KnownFolders]::SHSetKnownFolderPath([ref]$guid, 0, [IntPtr]::Zero, $TargetPath)
            if ($result -ne 0) {
                Write-Warning "  ⚠ SHSetKnownFolderPath returned code $result for GUID $guid"
            }
        }
        
        # Copy existing contents if requested
        if ($CopyContents) {
            $sourcePath = [Environment]::GetFolderPath($KnownFolderIdentifier)
            if ($sourcePath -and (Test-Path $sourcePath) -and ($sourcePath -ne $TargetPath)) {
                Write-Output "    Copying contents from $sourcePath..."
                Try {
                    Get-ChildItem -Path $sourcePath -Force | ForEach-Object {
                        Copy-Item -Path $_.FullName -Destination $TargetPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    Write-Output "    ✔ Contents copied"
                } Catch {
                    Write-Warning "    ⚠ Some files could not be copied: $_"
                }
            }
        }
        
        # Hide the old folder (if it's different from target)
        $oldPath = [Environment]::GetFolderPath($KnownFolderIdentifier)
        if ($oldPath -and (Test-Path $oldPath) -and ($oldPath -ne $TargetPath)) {
            Try {
                & attrib +h "$oldPath" 2>$null
            } Catch {
                # Attrib may fail silently, not critical
            }
        }
    }
    
    # Process each configured folder
    $successCount = 0
    $failureCount = 0
    
    ForEach ($folder in $listOfFoldersToRedirectToOneDriveForBusiness) {
        $targetPath = Join-Path $userFolder $folder.desiredSubFolderNameInOnedrive
        
        Write-Output ""
        Write-Output "  Processing: $($folder.knownFolderInternalName)"
        Write-Output "    Target: $targetPath"
        Write-Output "    Copy existing files: $($folder.copyContents)"
        
        Try {
            Redirect-Folder -KnownFolderIdentifier $folder.knownFolderInternalIdentifier `
                           -TargetPath $targetPath `
                           -CopyContents $folder.copyContents
            
            Write-Output "  ✔ Successfully redirected $($folder.knownFolderInternalName) → $targetPath"
            $successCount++
        } Catch {
            Write-Error "  ✖ Failed to redirect $($folder.knownFolderInternalName): $_"
            $failureCount++
        }
    }
    
    Write-Output ""
    Write-Output "Known Folder Move Summary:"
    Write-Output "  ✔ Successful: $successCount"
    if ($failureCount -gt 0) {
        Write-Output "  ✖ Failed: $failureCount"
    }
} else {
    Write-Output "[4/4] Known Folder Move disabled (skip)"
}

# ============================================================================
# COMPLETION
# ============================================================================

Write-Output ""
Write-Output "========================================="
Write-Output "OneDrive User Configuration Complete"
Write-Output "========================================="
Write-Output "Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output "Log file: $logFile"
Write-Output ""

Stop-Transcript
Exit 0
