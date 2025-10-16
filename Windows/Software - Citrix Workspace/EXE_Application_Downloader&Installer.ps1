<#
.SYNOPSIS
    Downloads and installs Citrix Workspace (or other EXE-based applications)

.DESCRIPTION
    Downloads an EXE installer from a URL and executes it with specified
    command-line arguments.
    
    Uses unique file naming to avoid conflicts during concurrent deployments.
    
    Parameters:
    - $DownloadUrl: URL to download the EXE installer
    - $InstallerArgs: Command-line arguments for silent installation
    
.NOTES
    FileName:    EXE_Application_Downloader&Installer.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     2.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: User
    - Context: 64 Bit
    - Internet connection required
    - Windows 10/11
    
    Exit Codes:
    - 0: Installation successful
    - 1: Download or installation failed
    
    Usage:
    powershell.exe -File EXE_Application_Downloader&Installer.ps1 -DownloadUrl "https://example.com/installer.exe" -InstallerArgs "/silent /norestart"
    
    Configuration:
    - For Citrix Workspace: Use "/silent /norestart /includeSSON" arguments
    - Customize arguments for other EXE installers
    
    Change Log:
    v2.0 - Unique file naming implementation
    v1.0 - Initial release
#>

param (
    [string]$DownloadUrl,
    [string]$InstallerArgs
)

# Function to download the executable
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

# Function to install the application silently
function Install-Application {
    param (
        [string]$installerPath,
        [string]$arguments
    )

    try {
        Write-Output "Starting silent installation of $installerPath with arguments $arguments"
        Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait
        Write-Output "Installation complete"
    } catch {
        Write-Error "Installation failed: $_"
        exit 1
    }
}

# Main script logic

# Generate a unique file name with timestamp
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$installerPath = "$env:TEMP\\installer_$timestamp.exe"

# Download the file
Download-File -url $DownloadUrl -output $installerPath

# Install the application with additional arguments
Install-Application -installerPath $installerPath -arguments $InstallerArgs

# Clean up
Remove-Item -Path $installerPath -Force
Write-Output "Cleanup complete"
