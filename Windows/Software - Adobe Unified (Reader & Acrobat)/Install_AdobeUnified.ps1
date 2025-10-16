<#
.SYNOPSIS
    Installs Adobe Acrobat DC

.DESCRIPTION
    Downloads and installs Adobe Acrobat DC (professional PDF editor).
    
    Downloads the full web installer package, extracts it, and runs the
    silent installation with enterprise deployment options.
    
.NOTES
    FileName:    Install_AdobeUnified.ps1
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
    - Sufficient disk space (~500MB)
    
    Exit Codes:
    - 0: Installation successful
    - 1: Installation failed
    
    External Dependencies:
    - Adobe Acrobat DC Web Installer (downloaded from Adobe)
    
    Impact:
    - Downloads ~400MB installer to temp folder
    - Installs Adobe Acrobat DC for all users
    - Requires internet connectivity during installation
    
    Change Log:
    v1.0 - Initial release
#>

$DownloadUrl = "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_x64_WWMUI.zip"
$TempPath = "$env:TEMP\AcrobatInstaller"
$ZipFile = "$TempPath\AcrobatInstaller.zip"
$ExtractPath = "$TempPath\Extracted"

# Create temporary folder
if (!(Test-Path $TempPath)) {
    New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
}

# Download the zip file
Write-Host "Downloading installer from $DownloadUrl..." -ForegroundColor Green
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile

# Extract the zip file
Write-Host "Extracting installer..." -ForegroundColor Green
if (!(Test-Path $ExtractPath)) {
    New-Item -ItemType Directory -Path $ExtractPath -Force | Out-Null
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $ExtractPath)

# Run the silent installer
$SetupExe = Join-Path -Path $ExtractPath -ChildPath "setup.exe"
if (Test-Path $SetupExe) {
    Write-Host "Running installer silently..." -ForegroundColor Green
    Start-Process -FilePath $SetupExe -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait -NoNewWindow
} else {
    Write-Error "Setup.exe not found in extracted files."
    exit 1
}

# Update registry keys
Write-Host "Updating registry keys..." -ForegroundColor Green
New-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat\DC\FeatureLockDown" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat\DC\FeatureLockDown" -Name "blsSCReducedModeEnforcedEx" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat\DC" -Name "bDontShowMsgWhenViewingDoc" -Value 0 -Type DWord

# Cleanup temporary files
Write-Host "Cleaning up temporary files..." -ForegroundColor Green
Remove-Item -Path $TempPath -Recurse -Force

Write-Host "Adobe Acrobat DC installation complete!" -ForegroundColor Cyan
