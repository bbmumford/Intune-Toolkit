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
}