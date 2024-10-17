<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: ZeroTier_Remediation.ps1
Description: Add device to input network.
Version 1.0: Init
Run as: System
Context: 64 Bit
Note: run with
    powershell.exe -ExecutionPolicy Bypass -File "./ZeroTier_Remediation.ps1"
#> 

# Variables
$networkID = "YOUR_NETWORK_ID"  # Replace with your actual network ID
$zeroTierService = "ZeroTier One"
$zeroTierCliPath = "C:\Program Files\ZeroTier\One\zerotier-cli.exe"

# Function to check if ZeroTier is installed
function Test-ZeroTierInstalled {
    try {
        return Get-Service -Name $zeroTierService -ErrorAction Stop
    } catch {
        Write-Host "Error: ZeroTier service not found. Exiting script."
        exit 1
    }
}

# Function to check if the device is already in the specified network
function Test-ZeroTierNetworkMembership {
    try {
        $networkStatus = & $zeroTierCliPath listnetworks
        return $networkStatus -match $networkID
    } catch {
        Write-Host "Error: Failed to execute ZeroTier CLI. Please ensure ZeroTier is installed."
        exit 1
    }
}

# Function to join the specified ZeroTier network
function Join-ZeroTierNetwork {
    try {
        Write-Host "Joining ZeroTier network $networkID..."
        & $zeroTierCliPath join $networkID

        # Check if the join command was successful
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully joined the ZeroTier network: $networkID."
        } else {
            Write-Host "Error: Failed to join the ZeroTier network. Please check the network ID."
            exit 1
        }
    } catch {
        Write-Host "Error: Exception occurred while joining the network. $_"
        exit 1
    }
}

# Main logic
if (-not (Test-ZeroTierInstalled)) {
    Write-Host "ZeroTier is not installed. Exiting script."
    exit 1
}

if (-not (Test-ZeroTierNetworkMembership)) {
    Join-ZeroTierNetwork
} else {
    Write-Host "Device is already a member of the ZeroTier network: $networkID."
    exit 0
}

