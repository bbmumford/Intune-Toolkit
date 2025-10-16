<#
.SYNOPSIS
    Rename Windows device to organizational standard format
.DESCRIPTION
    Renames a Windows device to the format: {OrgShort}-{SerialNumber}
    Example: ACME-ABC12345678
    
    This script can be deployed via Intune as a standalone script or used
    as part of a remediation when Intune's built-in rename fails.
    
.PARAMETER OrgShort
    Organization short name/prefix (e.g., "ACME", "CONTOSO")
    Default: "ORG" (should be customized before deployment)
    
.PARAMETER MaxNameLength
    Maximum computer name length (Windows limit is 15 characters)
    Default: 15
    
.NOTES
    Version: 1.1
    Author: Intune Toolkit
    Requires: Administrator privileges
    Requires: Windows 10/11
    
    Changelog:
    v1.1 - Added fallback methods for devices without valid serial numbers
         - Removed user prompts for fully automated execution
    v1.0 - Initial release
    
.EXAMPLE
    .\Rename-Device.ps1 -OrgShort "ACME"
    Renames device to ACME-{SerialNumber}
    
.EXAMPLE
    .\Rename-Device.ps1 -OrgShort "CONTOSO" -MaxNameLength 12
    Renames device with custom maximum length
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateLength(1, 10)]
    [string]$OrgShort = "ORG",
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 15)]
    [int]$MaxNameLength = 15
)

#region Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Color coding for console output
    switch ($Level) {
        'Info'    { Write-Host $logMessage -ForegroundColor Cyan }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $logMessage -ForegroundColor Red }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
    }
    
    # Also write to output stream for Intune logging
    Write-Output $logMessage
}

function Get-DeviceSerialNumber {
    try {
        # Try to get serial number from BIOS
        $serial = (Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop).SerialNumber
        
        # Clean serial number - remove invalid characters
        if (-not [string]::IsNullOrWhiteSpace($serial)) {
            $serial = $serial -replace '[^a-zA-Z0-9-]', ''
        }
        
        # If serial is empty or invalid, try fallback methods
        if ([string]::IsNullOrWhiteSpace($serial)) {
            Write-Log "BIOS serial number is empty or invalid, trying fallback methods..." -Level Warning
            
            # Fallback 1: Try UUID
            $uuid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct -ErrorAction SilentlyContinue).UUID
            if (-not [string]::IsNullOrWhiteSpace($uuid)) {
                # Use last 12 characters of UUID (removing hyphens)
                $serial = ($uuid -replace '-', '').Substring([Math]::Max(0, $uuid.Length - 12))
                Write-Log "Using UUID-based identifier: $serial" -Level Info
                return $serial
            }
            
            # Fallback 2: MAC Address (for VMs)
            $mac = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue | 
                    Where-Object { $_.IPEnabled -eq $true } | 
                    Select-Object -First 1).MACAddress
            if (-not [string]::IsNullOrWhiteSpace($mac)) {
                $serial = $mac -replace ':', '' -replace '-', ''
                Write-Log "Using MAC address-based identifier: $serial" -Level Info
                return $serial
            }
            
            # Fallback 3: Generate random identifier with UN prefix (Unknown)
            Write-Log "All hardware identifiers unavailable, generating random identifier" -Level Warning
            # Generate 8-character random alphanumeric string
            $random = -join ((48..57) + (65..90) | Get-Random -Count 8 | ForEach-Object {[char]$_})
            $serial = "UN$random"
            Write-Log "Using generated identifier: $serial (UN = Unknown device)" -Level Warning
            return $serial
        }
        
        Write-Log "Retrieved serial number: $serial" -Level Info
        return $serial
    }
    catch {
        Write-Log "Failed to retrieve serial number: $($_.Exception.Message)" -Level Error
        throw
    }
}

function Get-ValidComputerName {
    param(
        [string]$Prefix,
        [string]$SerialNumber,
        [int]$MaxLength
    )
    
    # Remove any invalid characters from prefix
    $Prefix = $Prefix -replace '[^a-zA-Z0-9-]', ''
    
    # Construct the name
    $proposedName = "$Prefix-$SerialNumber"
    
    # Ensure it doesn't start or end with hyphen
    $proposedName = $proposedName.Trim('-')
    
    # Truncate if necessary
    if ($proposedName.Length -gt $MaxLength) {
        Write-Log "Proposed name '$proposedName' exceeds $MaxLength characters. Truncating..." -Level Warning
        
        # Try to keep the full serial number if possible
        $serialLength = $SerialNumber.Length
        $prefixMaxLength = $MaxLength - $serialLength - 1 # -1 for the hyphen
        
        if ($prefixMaxLength -gt 0) {
            $truncatedPrefix = $Prefix.Substring(0, [Math]::Min($prefixMaxLength, $Prefix.Length))
            $proposedName = "$truncatedPrefix-$SerialNumber"
        }
        
        # If still too long, truncate serial number as last resort
        if ($proposedName.Length -gt $MaxLength) {
            $proposedName = $proposedName.Substring(0, $MaxLength)
        }
        
        Write-Log "Truncated name to: $proposedName" -Level Info
    }
    
    # Final validation
    if ($proposedName.Length -eq 0) {
        throw "Generated computer name is empty"
    }
    
    # Ensure no trailing hyphen after truncation
    $proposedName = $proposedName.TrimEnd('-')
    
    return $proposedName.ToUpper()
}

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Rename-Computer {
    param(
        [string]$NewName,
        [bool]$ForceRename
    )
    
    try {
        if ($ForceRename) {
            Rename-Computer -NewName $NewName -Force -ErrorAction Stop
        }
        else {
            Rename-Computer -NewName $NewName -ErrorAction Stop
        }
        
        Write-Log "Computer successfully renamed to: $NewName" -Level Success
        Write-Log "A restart is required for the name change to take effect" -Level Warning
        return $true
    }
    catch {
        Write-Log "Failed to rename computer: $($_.Exception.Message)" -Level Error
        return $false
    }
}

#endregion

#region Main Script

try {
    Write-Log "=== Device Rename Script Started ===" -Level Info
    
    # Check if running as administrator
    if (-not (Test-IsAdmin)) {
        Write-Log "This script must be run as Administrator" -Level Error
        exit 1
    }
    
    # Get current computer name
    $currentName = $env:COMPUTERNAME
    Write-Log "Current computer name: $currentName" -Level Info
    
    # Get serial number
    Write-Log "Retrieving device serial number..." -Level Info
    $serialNumber = Get-DeviceSerialNumber
    
    # Generate new computer name
    Write-Log "Generating new computer name with prefix: $OrgShort" -Level Info
    $newName = Get-ValidComputerName -Prefix $OrgShort -SerialNumber $serialNumber -MaxLength $MaxNameLength
    
    Write-Log "Proposed new computer name: $newName" -Level Info
    
    # Check if rename is needed
    if ($currentName -eq $newName) {
        Write-Log "Computer name is already correct: $newName" -Level Success
        Write-Log "No action needed" -Level Info
        exit 0
    }
    
    # Perform the rename (automatic, no confirmation needed)
    Write-Log "Renaming computer from '$currentName' to '$newName'..." -Level Info
    $success = Rename-Computer -NewName $newName -ForceRename $true
    
    if ($success) {
        Write-Log "=== Device Rename Completed Successfully ===" -Level Success
        Write-Log "IMPORTANT: Restart the computer to apply the new name" -Level Warning
        Write-Log "Device will be restarted automatically or by user/policy" -Level Info
        exit 0
    }
    else {
        Write-Log "=== Device Rename Failed ===" -Level Error
        exit 1
    }
}
catch {
    Write-Log "Unexpected error: $($_.Exception.Message)" -Level Error
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}

#endregion
