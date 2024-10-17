<#
Version: 3.0
Author: 
- Brandon Miller-Mumford
Script: Application_Downloader&Installer.ps1
Description:
Version 3.0: Combined EXE/MSI, added asynchronous download
Run as: System/User
Context: 64 Bit
#>

param (
    [string]$DownloadUrl,
    [string]$InstallerArgs
)

# Function to download the file asynchronously using BITS (Background Intelligent Transfer Service)
function Download-FileAsync {
    param (
        [string]$url,
        [string]$output
    )

    try {
        Write-Output "Starting asynchronous download of $url to $output"
        $bitsJob = Start-BitsTransfer -Source $url -Destination $output -Asynchronous
        $bitsJob | Wait-BitsTransfer
        Write-Output "Download complete"
    } catch {
        Write-Error "Failed to download file: $_"
        exit 1
    }
}

# Function to install EXE or MSI application silently
function Install-Application {
    param (
        [string]$installerPath,
        [string]$arguments
    )

    try {
        if ($installerPath -like "*.msi") {
            Write-Output "Starting silent MSI installation of $installerPath with arguments $arguments"
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" $arguments" -Wait
        } else {
            Write-Output "Starting silent EXE installation of $installerPath with arguments $arguments"
            Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait
        }
        Write-Output "Installation complete"
    } catch {
        Write-Error "Installation failed: $_"
        exit 1
    }
}

# Main script logic

# Generate a unique file name with timestamp
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$installerExtension = if ($DownloadUrl -match ".msi$") { ".msi" } else { ".exe" }
$installerPath = "$env:TEMP\\installer_$timestamp$installerExtension"

# Asynchronous download of the file
Download-FileAsync -url $DownloadUrl -output $installerPath

# Install the application with additional arguments
Install-Application -installerPath $installerPath -arguments $InstallerArgs

# Clean up
Remove-Item -Path $installerPath -Force
Write-Output "Cleanup complete"
