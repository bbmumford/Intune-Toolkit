<#
.SYNOPSIS
    Forces Windows 11 latest feature update installation bypassing Windows Update

.DESCRIPTION
    This script performs a forced in-place upgrade to the latest Windows 11 feature build.
    It downloads the official Windows 11 ISO from Microsoft, mounts it, and runs setup.exe
    directly with bypass flags. This method is more reliable than the Installation Assistant
    for devices that don't meet hardware requirements.
    
    Use cases:
    - Windows Update is stuck or broken
    - Component store corruption prevents normal updates
    - Feature updates fail repeatedly through normal channels
    - Devices without TPM 2.0 or Secure Boot need Windows 11
    
    The in-place upgrade preserves:
    - All installed applications
    - User data and profiles
    - System settings and configurations
    
.NOTES
    FileName:    Force-Windows11FeatureUpdate.ps1
    Author:      
    Created:     2026-01-08
    Modified:    2026-01-08
    Version:     2.0
    
    Requirements:
    - PowerShell 5.1+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10 20H1+ or Windows 11
    - Minimum 12GB free disk space (for ISO + upgrade)
    - Active internet connection
    
    Exit Codes:
    - 0: Upgrade initiated successfully
    - 1: Pre-requisite check failed
    - 2: Download failed
    - 3: Installation failed
    
    Intune Deployment:
    - Run this script as: System
    - Run script in 64-bit PowerShell: Yes
    - Enforcement: Run once or as needed
    
    IMPORTANT: Device will automatically restart to complete the upgrade.
    Schedule deployment during maintenance windows.
    
    Change Log:
    v2.0 - Switched to ISO download method for better hardware bypass support
    v1.0 - Initial release with Installation Assistant
#>

#region Configuration
# Paths
$WorkingDirectory = "$env:ProgramData\Intune\WindowsUpgrade"
$LogFile = "$WorkingDirectory\Windows11Upgrade_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$ISOPath = "$WorkingDirectory\Windows11.iso"

# Minimum free space required (in GB) - ISO is ~6GB + upgrade needs space
$MinFreeSpaceGB = 12

# Download timeout in seconds (ISO is large, allow more time)
$DownloadTimeout = 3600

# Bypass hardware requirements (TPM, Secure Boot, CPU, RAM checks)
# Set to $true for devices that don't meet Windows 11 hardware requirements
$BypassHardwareChecks = $true

# Windows 11 Edition to install (leave empty for auto-detect current edition)
# Options: "Windows 11 Home", "Windows 11 Pro", "Windows 11 Enterprise", "Windows 11 Education"
$TargetEdition = ""
#endregion

#region Functions
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO'
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # Create log directory if it doesn't exist
    if (-not (Test-Path (Split-Path $LogFile -Parent))) {
        New-Item -Path (Split-Path $LogFile -Parent) -ItemType Directory -Force | Out-Null
    }
    
    Add-Content -Path $LogFile -Value $LogMessage -Force
    
    switch ($Level) {
        'ERROR' { Write-Error $Message }
        'WARNING' { Write-Warning $Message }
        'SUCCESS' { Write-Host $Message -ForegroundColor Green }
        default { Write-Output $Message }
    }
}

function Test-Prerequisites {
    Write-Log "=== Checking Prerequisites ===" -Level INFO
    
    # Check if running as administrator/system
    $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "Script must be run as Administrator or System" -Level ERROR
        return $false
    }
    Write-Log "Running with Administrator privileges" -Level INFO
    
    # Check Windows version
    $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $OSVersion = [System.Environment]::OSVersion.Version
    Write-Log "Current OS: $($OSInfo.Caption) - Build $($OSInfo.BuildNumber)" -Level INFO
    
    # Must be Windows 10 or 11
    if ($OSVersion.Major -lt 10) {
        Write-Log "Windows 10 or later required for Windows 11 upgrade" -Level ERROR
        return $false
    }
    
    # Check architecture
    if (-not [Environment]::Is64BitOperatingSystem) {
        Write-Log "64-bit operating system required for Windows 11" -Level ERROR
        return $false
    }
    Write-Log "64-bit OS confirmed" -Level INFO
    
    # Check available disk space
    $SystemDrive = $env:SystemDrive
    $FreeSpace = (Get-PSDrive -Name $SystemDrive.TrimEnd(':')).Free / 1GB
    Write-Log "Free space on $SystemDrive : $([math]::Round($FreeSpace, 2)) GB" -Level INFO
    
    if ($FreeSpace -lt $MinFreeSpaceGB) {
        Write-Log "Insufficient disk space. Required: ${MinFreeSpaceGB}GB, Available: $([math]::Round($FreeSpace, 2))GB" -Level ERROR
        return $false
    }
    Write-Log "Disk space check passed" -Level INFO
    
    # Check internet connectivity
    try {
        $TestConnection = Test-NetConnection -ComputerName "www.microsoft.com" -Port 443 -WarningAction SilentlyContinue
        if (-not $TestConnection.TcpTestSucceeded) {
            throw "Connection test failed"
        }
        Write-Log "Internet connectivity confirmed" -Level INFO
    }
    catch {
        Write-Log "No internet connection available. Cannot download Windows 11." -Level ERROR
        return $false
    }
    
    # Check for pending reboots
    $PendingReboot = $false
    $RebootPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    )
    
    foreach ($Path in $RebootPaths) {
        if (Test-Path $Path) {
            $PendingReboot = $true
            break
        }
    }
    
    if ($PendingReboot) {
        Write-Log "Pending reboot detected. Continuing anyway - upgrade will handle this." -Level WARNING
    }
    
    # Log hardware status (informational only when bypass is enabled)
    if (-not $BypassHardwareChecks) {
        # Check TPM
        try {
            $TPM = Get-CimInstance -Namespace "root\cimv2\Security\MicrosoftTpm" -ClassName Win32_Tpm -ErrorAction SilentlyContinue
            if ($TPM -and $TPM.IsEnabled_InitialValue) {
                Write-Log "TPM is present and enabled" -Level INFO
            }
            else {
                Write-Log "TPM not present/enabled. Set BypassHardwareChecks=true if needed." -Level WARNING
            }
        }
        catch {
            Write-Log "Could not verify TPM status." -Level WARNING
        }
        
        # Check Secure Boot
        try {
            $SecureBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
            if ($SecureBoot) {
                Write-Log "Secure Boot is enabled" -Level INFO
            }
            else {
                Write-Log "Secure Boot not enabled. Set BypassHardwareChecks=true if needed." -Level WARNING
            }
        }
        catch {
            Write-Log "Could not verify Secure Boot status." -Level WARNING
        }
    }
    else {
        Write-Log "Hardware bypass is ENABLED - skipping TPM/SecureBoot checks" -Level WARNING
    }
    
    Write-Log "All critical prerequisites passed" -Level SUCCESS
    return $true
}

function Set-HardwareCheckBypass {
    Write-Log "=== Configuring Hardware Requirement Bypass ===" -Level INFO
    
    try {
        # Create registry key for setup bypass (MoSetup)
        $SetupPath = "HKLM:\SYSTEM\Setup\MoSetup"
        if (-not (Test-Path $SetupPath)) {
            New-Item -Path $SetupPath -Force | Out-Null
        }
        
        # AllowUpgradesWithUnsupportedTPMOrCPU - Main bypass for in-place upgrades
        Set-ItemProperty -Path $SetupPath -Name "AllowUpgradesWithUnsupportedTPMOrCPU" -Value 1 -Type DWord -Force
        Write-Log "Set AllowUpgradesWithUnsupportedTPMOrCPU = 1" -Level INFO
        
        # LabConfig bypass keys (used by setup.exe)
        $LabConfigPath = "HKLM:\SYSTEM\Setup\LabConfig"
        if (-not (Test-Path $LabConfigPath)) {
            New-Item -Path $LabConfigPath -Force | Out-Null
        }
        
        $BypassKeys = @{
            "BypassTPMCheck"        = 1
            "BypassSecureBootCheck" = 1
            "BypassRAMCheck"        = 1
            "BypassStorageCheck"    = 1
            "BypassCPUCheck"        = 1
        }
        
        foreach ($Key in $BypassKeys.GetEnumerator()) {
            Set-ItemProperty -Path $LabConfigPath -Name $Key.Name -Value $Key.Value -Type DWord -Force
            Write-Log "Set $($Key.Name) = $($Key.Value)" -Level INFO
        }
        
        Write-Log "Hardware requirement bypass configured successfully" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "Failed to configure hardware bypass: $_" -Level ERROR
        return $false
    }
}

function Stop-WindowsUpdateServices {
    Write-Log "=== Stopping Windows Update Services ===" -Level INFO
    
    $Services = @('wuauserv', 'bits', 'cryptsvc', 'msiserver')
    
    foreach ($Service in $Services) {
        try {
            $Svc = Get-Service -Name $Service -ErrorAction SilentlyContinue
            if ($Svc -and $Svc.Status -eq 'Running') {
                Stop-Service -Name $Service -Force -ErrorAction Stop
                Write-Log "Stopped service: $Service" -Level INFO
            }
        }
        catch {
            Write-Log "Could not stop service $Service : $_" -Level WARNING
        }
    }
}

function Clear-WindowsUpdateCache {
    Write-Log "=== Clearing Windows Update Cache ===" -Level INFO
    
    $CachePaths = @(
        "$env:SystemRoot\SoftwareDistribution\Download",
        "$env:SystemRoot\System32\catroot2"
    )
    
    foreach ($Path in $CachePaths) {
        if (Test-Path $Path) {
            try {
                Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | 
                    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Write-Log "Cleared cache: $Path" -Level INFO
            }
            catch {
                Write-Log "Could not fully clear $Path : $_" -Level WARNING
            }
        }
    }
}

function Start-WindowsUpdateServices {
    Write-Log "=== Starting Windows Update Services ===" -Level INFO
    
    $Services = @('cryptsvc', 'bits', 'wuauserv', 'msiserver')
    
    foreach ($Service in $Services) {
        try {
            $Svc = Get-Service -Name $Service -ErrorAction SilentlyContinue
            if ($Svc) {
                Start-Service -Name $Service -ErrorAction Stop
                Write-Log "Started service: $Service" -Level INFO
            }
        }
        catch {
            Write-Log "Could not start service $Service : $_" -Level WARNING
        }
    }
}

function Get-Windows11ISO {
    Write-Log "=== Downloading Windows 11 ISO ===" -Level INFO
    
    # Create working directory
    if (-not (Test-Path $WorkingDirectory)) {
        New-Item -Path $WorkingDirectory -ItemType Directory -Force | Out-Null
        Write-Log "Created working directory: $WorkingDirectory" -Level INFO
    }
    
    # Clean up any previous ISO
    if (Test-Path $ISOPath) {
        Write-Log "Removing existing ISO file" -Level INFO
        Remove-Item -Path $ISOPath -Force -ErrorAction SilentlyContinue
    }
    
    try {
        # Download Media Creation Tool
        $MCTPath = "$WorkingDirectory\MediaCreationTool.exe"
        $MCTUrl = "https://go.microsoft.com/fwlink/?linkid=2156295"
        
        Write-Log "Downloading Media Creation Tool from: $MCTUrl" -Level INFO
        
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Try BITS first
        try {
            $BitsJob = Start-BitsTransfer -Source $MCTUrl -Destination $MCTPath -Asynchronous
            
            $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            while ($BitsJob.JobState -eq 'Transferring' -or $BitsJob.JobState -eq 'Connecting') {
                Start-Sleep -Seconds 2
                if ($Stopwatch.Elapsed.TotalSeconds -gt 300) {
                    $BitsJob | Remove-BitsTransfer
                    throw "MCT download timeout"
                }
            }
            
            if ($BitsJob.JobState -eq 'Transferred') {
                $BitsJob | Complete-BitsTransfer
                Write-Log "Media Creation Tool downloaded via BITS" -Level SUCCESS
            }
            else {
                throw "BITS transfer state: $($BitsJob.JobState)"
            }
        }
        catch {
            Write-Log "BITS failed, trying WebClient: $_" -Level WARNING
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($MCTUrl, $MCTPath)
            Write-Log "Media Creation Tool downloaded via WebClient" -Level SUCCESS
        }
        
        if (-not (Test-Path $MCTPath)) {
            throw "Media Creation Tool download failed"
        }
        
        # Run Media Creation Tool to download ISO
        Write-Log "Running Media Creation Tool to download Windows 11 ISO..." -Level INFO
        Write-Log "This may take 15-45 minutes depending on internet speed" -Level INFO
        
        # MCT arguments for creating an ISO
        # /Eula Accept - Accept EULA
        # /Retail - Use retail media
        # /MediaArch x64 - 64-bit
        # /MediaLangCode en-US - English
        # /MediaEdition Professional - Pro edition (can also be empty for multi-edition)
        # /ISO - Create ISO file
        $MCTArguments = "/Eula Accept /Retail /MediaArch x64 /MediaLangCode en-US /ISO `"$ISOPath`""
        
        Write-Log "MCT Arguments: $MCTArguments" -Level INFO
        
        $MCTProcess = Start-Process -FilePath $MCTPath -ArgumentList $MCTArguments -Wait -PassThru -WindowStyle Hidden
        
        Write-Log "Media Creation Tool exited with code: $($MCTProcess.ExitCode)" -Level INFO
        
        # Check if ISO was created
        if (Test-Path $ISOPath) {
            $ISOSize = (Get-Item $ISOPath).Length / 1GB
            Write-Log "Windows 11 ISO downloaded successfully. Size: $([math]::Round($ISOSize, 2)) GB" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "MCT didn't create ISO, will use Installation Assistant fallback" -Level WARNING
            $script:UseAssistantFallback = $true
            return $true
        }
    }
    catch {
        Write-Log "ISO download failed: $_" -Level WARNING
        $script:UseAssistantFallback = $true
        return $true
    }
}

function Start-Windows11UpgradeFromISO {
    Write-Log "=== Starting Windows 11 Upgrade ===" -Level INFO
    
    $MountedDrive = $null
    
    # Check if we're using the Installation Assistant fallback
    if ($script:UseAssistantFallback -or -not (Test-Path $ISOPath)) {
        Write-Log "Using Installation Assistant method" -Level INFO
        return Start-Windows11UpgradeFromAssistant
    }
    
    try {
        # Mount the ISO
        Write-Log "Mounting ISO: $ISOPath" -Level INFO
        $MountResult = Mount-DiskImage -ImagePath $ISOPath -PassThru
        $MountedDrive = ($MountResult | Get-Volume).DriveLetter + ":"
        Write-Log "ISO mounted at: $MountedDrive" -Level INFO
        
        # Verify setup.exe exists
        $SetupPath = "$MountedDrive\setup.exe"
        if (-not (Test-Path $SetupPath)) {
            throw "setup.exe not found in ISO at $SetupPath"
        }
        
        # Build setup arguments for silent in-place upgrade
        # Key arguments for bypassing hardware checks and running unattended
        $SetupArguments = @(
            "/Auto Upgrade"                    # Perform upgrade keeping apps and files
            "/Quiet"                           # Suppress all UI
            "/DynamicUpdate Disable"           # Disable dynamic updates (faster)
            "/MigrateDrivers All"              # Migrate all drivers
            "/ShowOOBE None"                   # Skip OOBE screens
            "/Compat IgnoreWarning"            # CRITICAL: Ignore compatibility warnings including TPM/SecureBoot
            "/Priority High"                   # High priority for faster processing
            "/Telemetry Disable"               # Disable telemetry during upgrade
            "/CopyLogs `"$WorkingDirectory`""  # Copy setup logs for troubleshooting
        )
        
        $ArgumentString = $SetupArguments -join " "
        Write-Log "Setup.exe arguments: $ArgumentString" -Level INFO
        
        # Start the upgrade process
        Write-Log "Starting Windows 11 setup.exe from ISO..." -Level INFO
        
        $SetupProcess = Start-Process -FilePath $SetupPath -ArgumentList $ArgumentString -PassThru -WindowStyle Hidden
        
        # Wait a bit to see if it starts properly
        Start-Sleep -Seconds 30
        
        if ($SetupProcess -and -not $SetupProcess.HasExited) {
            Write-Log "Windows 11 setup started successfully (PID: $($SetupProcess.Id))" -Level SUCCESS
            Write-Log "The upgrade will continue in the background" -Level INFO
            Write-Log "Device will restart automatically when ready" -Level INFO
            
            # Don't unmount ISO - setup needs it
            return $true
        }
        elseif ($SetupProcess -and $SetupProcess.HasExited) {
            $ExitCode = $SetupProcess.ExitCode
            Write-Log "Setup.exe exited with code: $ExitCode (0x$($ExitCode.ToString('X')))" -Level WARNING
            
            # Common exit codes
            switch ($ExitCode) {
                0 { 
                    Write-Log "Setup completed successfully or already up to date" -Level SUCCESS
                    return $true 
                }
                -1047526896 { # 0xC1900208
                    Write-Log "Compatibility issue detected - trying with additional bypasses" -Level WARNING
                    Dismount-DiskImage -ImagePath $ISOPath -ErrorAction SilentlyContinue
                    return Start-Windows11UpgradeFromAssistant
                }
                -1047526904 { # 0xC1900200
                    Write-Log "Hardware requirements not met - trying Installation Assistant" -Level WARNING
                    Dismount-DiskImage -ImagePath $ISOPath -ErrorAction SilentlyContinue
                    return Start-Windows11UpgradeFromAssistant
                }
                3010 { 
                    Write-Log "Reboot required to complete" -Level SUCCESS
                    return $true 
                }
                default { 
                    Write-Log "Setup exited, checking if upgrade is in progress..." -Level INFO
                    # Check if Windows setup is running
                    $SetupRunning = Get-Process -Name "SetupHost" -ErrorAction SilentlyContinue
                    if ($SetupRunning) {
                        Write-Log "Windows Setup is running in background" -Level SUCCESS
                        return $true
                    }
                    Write-Log "Trying Installation Assistant fallback" -Level WARNING
                    Dismount-DiskImage -ImagePath $ISOPath -ErrorAction SilentlyContinue
                    return Start-Windows11UpgradeFromAssistant
                }
            }
        }
        else {
            throw "Failed to start setup process"
        }
    }
    catch {
        Write-Log "ISO upgrade failed: $_" -Level ERROR
        
        # Try to unmount on failure
        if ($MountedDrive -or (Test-Path $ISOPath)) {
            try {
                Dismount-DiskImage -ImagePath $ISOPath -ErrorAction SilentlyContinue
            }
            catch { }
        }
        
        # Fall back to Installation Assistant
        Write-Log "Attempting fallback to Installation Assistant..." -Level WARNING
        return Start-Windows11UpgradeFromAssistant
    }
}

function Start-Windows11UpgradeFromAssistant {
    Write-Log "=== Starting Windows 11 Upgrade via Installation Assistant ===" -Level INFO
    
    $AssistantPath = "$WorkingDirectory\Windows11InstallationAssistant.exe"
    $AssistantUrl = "https://go.microsoft.com/fwlink/?linkid=2171764"
    
    # Download if not present
    if (-not (Test-Path $AssistantPath)) {
        Write-Log "Downloading Installation Assistant from: $AssistantUrl" -Level INFO
        
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            
            # Try BITS first
            try {
                Start-BitsTransfer -Source $AssistantUrl -Destination $AssistantPath -ErrorAction Stop
                Write-Log "Installation Assistant downloaded via BITS" -Level SUCCESS
            }
            catch {
                Write-Log "BITS failed, trying WebClient" -Level WARNING
                $WebClient = New-Object System.Net.WebClient
                $WebClient.DownloadFile($AssistantUrl, $AssistantPath)
                Write-Log "Installation Assistant downloaded via WebClient" -Level SUCCESS
            }
        }
        catch {
            Write-Log "Failed to download Installation Assistant: $_" -Level ERROR
            return $false
        }
    }
    
    if (-not (Test-Path $AssistantPath)) {
        Write-Log "Installation Assistant not found at: $AssistantPath" -Level ERROR
        return $false
    }
    
    try {
        # Installation Assistant arguments
        $Arguments = @(
            "/QuietInstall"
            "/SkipEULA"
            "/Auto Upgrade"
            "/MigrateDrivers all"
            "/ShowOOBE none"
            "/DynamicUpdate enable"
            "/Compat IgnoreWarning"
            "/Priority high"
        )
        
        $ArgumentString = $Arguments -join " "
        Write-Log "Installation Assistant arguments: $ArgumentString" -Level INFO
        
        # Create scheduled task for reliability (runs even if this script exits)
        $TaskName = "Windows11FeatureUpgrade"
        
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
        
        $TaskAction = New-ScheduledTaskAction -Execute $AssistantPath -Argument $ArgumentString
        $TaskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(2)
        $TaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        
        Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskSettings -Force | Out-Null
        Write-Log "Scheduled task created: $TaskName" -Level INFO
        
        # Also start directly for immediate execution
        Write-Log "Launching Installation Assistant..." -Level INFO
        $Process = Start-Process -FilePath $AssistantPath -ArgumentList $ArgumentString -PassThru -WindowStyle Hidden
        
        Start-Sleep -Seconds 15
        
        if ($Process -and -not $Process.HasExited) {
            Write-Log "Installation Assistant started (PID: $($Process.Id))" -Level SUCCESS
            Write-Log "The upgrade will download Windows 11 and restart automatically" -Level INFO
            return $true
        }
        elseif ($Process -and ($Process.ExitCode -eq 0 -or $Process.ExitCode -eq 3010)) {
            Write-Log "Upgrade initiated successfully (Exit: $($Process.ExitCode))" -Level SUCCESS
            return $true
        }
        else {
            # Start via scheduled task as backup
            Write-Log "Direct launch completed, scheduled task will run as backup" -Level INFO
            Start-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
            return $true
        }
    }
    catch {
        Write-Log "Installation Assistant failed: $_" -Level ERROR
        return $false
    }
}

function Invoke-WindowsRepairBeforeUpgrade {
    Write-Log "=== Running Pre-Upgrade System Repair ===" -Level INFO
    
    try {
        Write-Log "Running DISM RestoreHealth (this may take 10-15 minutes)..." -Level INFO
        $DISMResult = Start-Process -FilePath "DISM.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -PassThru -WindowStyle Hidden
        Write-Log "DISM completed with exit code: $($DISMResult.ExitCode)" -Level INFO
    }
    catch {
        Write-Log "DISM repair failed: $_" -Level WARNING
    }
    
    try {
        Write-Log "Running System File Checker..." -Level INFO
        $SFCResult = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -PassThru -WindowStyle Hidden
        Write-Log "SFC completed with exit code: $($SFCResult.ExitCode)" -Level INFO
    }
    catch {
        Write-Log "SFC repair failed: $_" -Level WARNING
    }
}
#endregion

#region Main Execution
$script:UseAssistantFallback = $false

try {
    Write-Log "========================================" -Level INFO
    Write-Log "Windows 11 Force Feature Update Script" -Level INFO
    Write-Log "Version 2.0 - ISO + Installation Assistant" -Level INFO
    Write-Log "========================================" -Level INFO
    Write-Log "Script started at: $(Get-Date)" -Level INFO
    Write-Log "Computer Name: $env:COMPUTERNAME" -Level INFO
    Write-Log "Current User: $env:USERNAME" -Level INFO
    Write-Log "Hardware Bypass: $BypassHardwareChecks" -Level INFO
    
    # Step 1: Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Log "Prerequisite check failed. Aborting." -Level ERROR
        exit 1
    }
    
    # Step 2: Configure hardware bypass if enabled
    if ($BypassHardwareChecks) {
        Write-Log "Configuring hardware requirement bypass..." -Level INFO
        if (-not (Set-HardwareCheckBypass)) {
            Write-Log "Failed to set hardware bypass - continuing anyway" -Level WARNING
        }
    }
    
    # Step 3: Optional - Run system repair
    # Uncomment the following line to run DISM/SFC before upgrade:
    # Invoke-WindowsRepairBeforeUpgrade
    
    # Step 4: Stop Windows Update services and clear cache
    Stop-WindowsUpdateServices
    Clear-WindowsUpdateCache
    Start-WindowsUpdateServices
    
    # Step 5: Download Windows 11 (ISO or prepare for Assistant)
    Write-Log "Downloading Windows 11..." -Level INFO
    $DownloadSuccess = Get-Windows11ISO
    
    if (-not $DownloadSuccess) {
        Write-Log "Download preparation failed" -Level ERROR
        exit 2
    }
    
    # Step 6: Start the upgrade
    if (-not (Start-Windows11UpgradeFromISO)) {
        Write-Log "Failed to start Windows 11 upgrade" -Level ERROR
        exit 3
    }
    
    Write-Log "========================================" -Level SUCCESS
    Write-Log "Windows 11 upgrade initiated successfully!" -Level SUCCESS
    Write-Log "The device will download updates and restart automatically." -Level SUCCESS
    Write-Log "This process may take 30-90 minutes depending on hardware." -Level SUCCESS
    Write-Log "Log file: $LogFile" -Level INFO
    Write-Log "========================================" -Level SUCCESS
    
    exit 0
}
catch {
    Write-Log "Unhandled exception: $_" -Level ERROR
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Level ERROR
    exit 1
}
#endregion
