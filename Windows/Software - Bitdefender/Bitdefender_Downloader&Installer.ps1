<#
.SYNOPSIS
    Downloads and installs Bitdefender antivirus

.DESCRIPTION
    Downloads Bitdefender installer package from URL and executes MSI
    installation with specified package ID.
    
    Automates Bitdefender deployment for enterprise environments using
    the Bitdefender GravityZone package download mechanism.
    
    Parameters:
    - $DownloadUrl: URL to download Bitdefender installer
    - $PackageID: Bitdefender package identifier for licensing
    
.NOTES
    FileName:    Bitdefender_Downloader&Installer.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Internet connection required
    - Windows 10/11
    
    Exit Codes:
    - 0: Installation successful
    - 1: Download or installation failed
    
    External Dependencies:
    - Bitdefender GravityZone package
    - Valid Bitdefender package ID
    
    Usage:
    powershell.exe -File Bitdefender_Downloader&Installer.ps1 -DownloadUrl "https://download.bitdefender.com/..." -PackageID "your_package_id"
    
    Configuration:
    - Obtain DownloadUrl from Bitdefender GravityZone console
    - Obtain PackageID from Bitdefender GravityZone console
    
    Impact:
    - Installs endpoint protection (may affect performance during scan)
    - Enables real-time protection and firewall
    - May require system restart
    
    Change Log:
    v1.0 - Initial release
#>

param (
    [string]$DownloadUrl,
    [string]$PackageID
)

# Function to download the MSI file
function Download-File {
    param (
        [string]$url,
        [string]$output
    )

    try {
        Write-Output "Downloading $url to $output"
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        Write-Output "Download complete"
    } catch {
        Write-Error "Failed to download file: $_"
        exit 1
    }
}

# Function to install the MSI application silently
function Install-Application {
    param (
        [string]$installerPath,
        [string]$ID
    )

    try {
        Write-Output "Starting silent installation of $installerPath with packageID $ID"
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /qn GZ_PACKAGE_ID=$ID REBOOT_IF_NEEDED=1" -Wait
        Write-Output "Installation complete"
    } catch {
        Write-Error "Installation failed: $_"
        exit 1
    }
}

# Generate a unique file name with timestamp
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$installerPath = "$env:TEMP\\installer_$timestamp.msi"

# Download the file
Download-File -url $DownloadUrl -output $installerPath

# Install the application with additional arguments
Install-Application -installerPath $installerPath -arguments $PackageID

# Clean up
Remove-Item -Path $installerPath -Force
Write-Output "Cleanup complete"
