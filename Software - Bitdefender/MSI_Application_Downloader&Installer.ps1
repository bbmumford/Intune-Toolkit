<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: MSI_Application_Downloader&Installer.ps1
Description:
Version 1.0: Init
Run as: System
Context: 64 Bit
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

# Main script logic
$installerPath = "$env:TEMP\installer.msi"

# Download the file
Download-File -url $DownloadUrl -output $installerPath

# Install the application with additional arguments
Install-Application -installerPath $installerPath -arguments $PackageID

# Clean up
Remove-Item -Path $installerPath -Force
Write-Output "Cleanup complete"
