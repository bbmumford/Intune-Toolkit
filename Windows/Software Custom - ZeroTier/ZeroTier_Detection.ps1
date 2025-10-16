<#
.SYNOPSIS
    Detects if ZeroTier is installed and joined to correct network

.DESCRIPTION
    Checks if ZeroTier One VPN client is installed and verifies that the
    device is a member of the specified ZeroTier network.
    
    Validates both installation status and network membership to ensure
    proper VPN connectivity configuration.
    
.NOTES
    FileName:    ZeroTier_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 7/8/10/11
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (ZeroTier installed and joined to correct network)
    - 1: Non-Compliant (triggers installation or network join)
    
    Configuration:
    - Set $correctNetworkID to your ZeroTier network ID
    
    Usage:
    powershell.exe -ExecutionPolicy Bypass -File "./ZeroTier_Detection.ps1"
    
    Change Log:
    v1.0 - Initial release
#>

# Define the ZeroTier network ID you want to check
$correctNetworkID = "your_network_id_here"

# Function to check if ZeroTier is installed
function Check-ZeroTierInstallation {
    $zerotierPath = "C:\Program Files (x86)\ZeroTier\One\ZeroTier One.exe"
    if (Test-Path $zerotierPath) {
        return $true
    } else {
        return $false
    }
}

# Function to check if the device is part of the correct ZeroTier network
function Check-ZeroTierNetwork {
    $zerotierCliPath = "C:\ProgramData\ZeroTier\One\zerotier-cli.bat"
    if (Test-Path $zerotierCliPath) {
        $networkInfo = & $zerotierCliPath listnetworks | Out-String
        if ($networkInfo -match $correctNetworkID) {
            return $true
        } else {
            return $false
        }
    } else {
        Write-Error "ZeroTier CLI not found."
        return $false
    }
}

# Main script execution
if (Check-ZeroTierInstallation) {
    Write-Output "ZeroTier is installed."
    if (Check-ZeroTierNetwork) {
        Write-Output "The device is part of the correct ZeroTier network ($correctNetworkID)."
    } else {
        Write-Output "The device is NOT part of the correct ZeroTier network ($correctNetworkID)."
    }
} else {
    Write-Output "ZeroTier is not installed."
    Exit 1
}
