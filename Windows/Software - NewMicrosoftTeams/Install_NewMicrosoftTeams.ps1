<#
.SYNOPSIS
    Installs New Microsoft Teams (Teams 2.0)

.DESCRIPTION
    Downloads and installs the new Microsoft Teams client using the Teams
    Bootstrapper deployment method.
    
    Downloads the Teams MSIX package and installs it in provisioned mode
    for all users on the system.
    
.NOTES
    FileName:    Install_NewMicrosoftTeams.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Internet connection required
    - Windows 10 1809+ or Windows 11
    
    Exit Codes:
    - 0: Installation successful
    - 1: Installation failed
    
    External Dependencies:
    - teamsbootstrapper.exe (must be in same directory)
    - MSTeams MSIX package (downloaded from Microsoft)
    
    Impact:
    - Installs Teams 2.0 for all users
    - Downloads ~100MB installer to temp folder
    - Requires internet connectivity during installation
    
    Change Log:
    v1.0 - Initial release
#>

# Define paths and filenames
$msixFile = "$env:temp\MSTeams-x64.msix"
$msixUrl = "https://go.microsoft.com/fwlink/?linkid=2196106"
$bootstrapperPath = ".\teamsbootstrapper.exe"

# Download MSTeams-x64.msix to the temp directory
try {
    Invoke-WebRequest -Uri $msixUrl -OutFile $msixFile
    Write-Host "MSTeams-x64.msix downloaded successfully."
} catch {
    Write-Host "Error: Failed to download MSTeams-x64.msix."
    exit 1
}

# Check if the download operation was successful
if (Test-Path -Path $msixFile) {
    # If successful, execute teamsbootstrapper.exe with specified parameters
    Start-Process -FilePath $bootstrapperPath -ArgumentList "-p", "-o", $msixFile -Wait -WindowStyle Hidden
    Write-Host "Microsoft Teams installation completed successfully."
} else {
    # If download operation failed, display an error message
    Write-Host "Error: MSTeams-x64.msix file not found."
    exit 1
}
