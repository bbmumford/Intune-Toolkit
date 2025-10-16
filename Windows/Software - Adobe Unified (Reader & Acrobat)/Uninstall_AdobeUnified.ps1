<#
.SYNOPSIS
    Uninstalls Adobe Acrobat DC

.DESCRIPTION
    Removes Adobe Acrobat DC from the system by locating and executing
    the uninstaller from the registry.
    
    Searches the Windows registry for the Adobe Acrobat DC uninstall string
    and executes it silently.
    
.NOTES
    FileName:    Uninstall_AdobeUnified.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    
    Exit Codes:
    - 0: Uninstallation successful
    - 1: Uninstallation failed or product not found
    
    Impact:
    - Removes Adobe Acrobat DC completely
    - PDF association may revert to default Windows reader
    
    Change Log:
    v1.0 - Initial release
#>

$ProductName = "Adobe Acrobat DC"
$UninstallKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$TempPath = "$env:TEMP\AcrobatUninstall"

# Function to find the Uninstall String
function Get-UninstallString {
    Write-Host "Searching for $ProductName in installed programs..." -ForegroundColor Green
    $uninstallString = Get-ChildItem -Path $UninstallKeyPath |
        Where-Object { (Get-ItemProperty $_.PSPath).DisplayName -like "*$ProductName*" } |
        ForEach-Object { (Get-ItemProperty $_.PSPath).UninstallString }

    if (!$uninstallString) {
        Write-Error "$ProductName is not installed or cannot be found."
        exit 1
    }

    return $uninstallString
}

# Fetch the Uninstall String
$UninstallString = Get-UninstallString

# Adjust Uninstall String if required
if ($UninstallString -like "*.exe*") {
    $UninstallCommand = "$UninstallString /s"
} elseif ($UninstallString -like "*.msi*") {
    $UninstallCommand = "msiexec /x $UninstallString /qn"
} else {
    Write-Error "Unsupported uninstall string format."
    exit 1
}

# Run the Uninstall Command
Write-Host "Uninstalling $ProductName silently..." -ForegroundColor Green
Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $UninstallCommand -Wait -NoNewWindow

# Cleanup registry keys
Write-Host "Removing registry keys..." -ForegroundColor Green
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat\DC\FeatureLockDown" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat\DC" -Recurse -Force -ErrorAction SilentlyContinue

# Confirm uninstallation
Write-Host "$ProductName uninstallation complete!" -ForegroundColor Cyan
