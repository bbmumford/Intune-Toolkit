# Variables
$restorePointDescription = "Restore Point Created by Intune Remediation Script"
$restorePointType = 12 # MODIFY_SETTINGS
$maxUsageMB = 10240 # Maximum disk usage for system protection (10 GB)
$maxRetries = 3 # Number of retries for enabling system protection

# Embedded C# Code to Manage Restore Points
$csCode = @"
using System;
using System.Runtime.InteropServices;

public class RestorePointManager
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct RestorePointInfo
    {
        public int EventType;
        public int RestorePointType;
        public long SequenceNumber;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
        public string Description;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct StateManagerStatus
    {
        public int Status;
        public int SequenceNumber;
    }

    public const int BeginSystemChange = 100; // Start a system change
    public const int ModifySettings = 12; // Restore point type: Modify settings

    [DllImport("srclient.dll")]
    public static extern int SRSetRestorePointW(ref RestorePointInfo restorePtInfo, out StateManagerStatus smStatus);

    public static int CreateRestorePoint(string description, int restorePointType)
    {
        RestorePointInfo restorePointInfo = new RestorePointInfo
        {
            EventType = BeginSystemChange,
            RestorePointType = restorePointType,
            SequenceNumber = 0,
            Description = description
        };

        StateManagerStatus smStatus;
        return SRSetRestorePointW(ref restorePointInfo, out smStatus);
    }
}
"@

# Compile and Load Restore Point Manager
$assemblyPath = "$env:temp\RestorePointManager_$([guid]::NewGuid().ToString()).dll"
if (Test-Path $assemblyPath) {
    Remove-Item $assemblyPath -Force
}
Add-Type -TypeDefinition $csCode -Language CSharp -OutputAssembly $assemblyPath
[Reflection.Assembly]::LoadFile($assemblyPath)

# Function to Ensure Shadow Copy Service is Running
function Ensure-VSS {
    Write-Output "Ensuring Volume Shadow Copy Service (VSS) is running..."
    $service = Get-Service -Name "VSS" -ErrorAction SilentlyContinue
    if ($service -and $service.Status -ne "Running") {
        Start-Service -Name "VSS" -ErrorAction Stop
        Write-Output "Volume Shadow Copy Service started successfully."
    } elseif (-not $service) {
        Write-Output "Volume Shadow Copy Service (VSS) is not installed or accessible. Exiting remediation."
        exit 1
    } else {
        Write-Output "Volume Shadow Copy Service is already running."
    }
}

# Function to Enable System Protection
function Enable-SystemProtection {
    Write-Output "Checking and enabling system protection on C:\\..."
    try {
        Enable-ComputerRestore -Drive "C:" -ErrorAction Stop
        Start-Sleep -Seconds 2

        $shadowStorage = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_ShadowStorage" |
            Where-Object { $_.Volume -eq "C:\\" }
        if ($shadowStorage) {
            Write-Output "System protection successfully enabled with shadow storage configured."
            return $true
        } else {
            Write-Output "Failed to verify system protection. Shadow storage not configured."
            return $false
        }
    } catch {
        Write-Output "Failed to enable system protection: $_"
        return $false
    }
}

# Function to Configure Maximum Disk Usage
function Configure-DiskUsage {
    Write-Output "Configuring maximum disk usage for system protection on C:\\..."
    try {
        Start-Process -FilePath "vssadmin" -ArgumentList "resize shadowstorage /for=C: /on=C: /maxsize=${maxUsageMB}MB" -NoNewWindow -Wait
        Write-Output "Maximum disk usage for system protection set to ${maxUsageMB} MB."
        return $true
    } catch {
        Write-Output "Failed to configure maximum disk usage: $_"
        return $false
    }
}

# Function to Create Restore Point
function Create-RestorePoint {
    Write-Output "Creating a new system restore point..."
    $result = [RestorePointManager]::CreateRestorePoint($restorePointDescription, $restorePointType)
    if ($result -eq 0) {
        Write-Output "Restore point created successfully."
    } elseif ($result -eq 1) {
        Write-Output "Warning: Restore point created but encountered a non-critical issue (code: $result)."
    } else {
        Write-Output "Failed to create restore point. Error code: $result. Ensure sufficient permissions and space."
        exit 1
    }
}

# Main Script Logic
try {
    # Ensure VSS is running
    Ensure-VSS

    # Enable and check system protection
    if (-not (Enable-SystemProtection)) {
        Write-Output "System protection could not be enabled. Exiting remediation."
        exit 1
    }

    # Configure disk usage after enabling system protection
    if (-not (Configure-DiskUsage)) {
        Write-Output "Failed to configure disk usage. Exiting remediation."
        exit 1
    }

    # Query existing restore points
    Write-Output "Querying existing restore points..."
    $restorePoints = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
    if (-not $restorePoints) {
        Write-Output "No restore points exist. A new restore point will be created."
    }

    # Create a new restore point
    Create-RestorePoint

    # Exit with success code
    exit 0
} catch {
    Write-Output "Error occurred during remediation: $_"
    exit 1
}
