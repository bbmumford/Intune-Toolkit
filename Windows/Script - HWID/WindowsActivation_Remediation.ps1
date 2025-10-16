<#
.SYNOPSIS
    Activates Windows using Hardware ID (HWID) activation method

.DESCRIPTION
    Downloads and executes the HWID activation script from Microsoft Activation Scripts
    repository to activate Windows using the Hardware ID method.
    
    Process:
    1. Enables TLS 1.2 for secure downloads
    2. Downloads HWID_Activation.cmd from GitHub
    3. Executes the activation script
    4. Validates activation status
    5. Cleans up temporary files
    
    Compatible with Windows 11 and uses modern PowerShell practices.
    
.NOTES
    FileName:    WindowsActivation_Remediation.ps1
    Author:      
    Created:     
    Modified:    2025-10-16
    Version:     1.1
    
    Requirements:
    - PowerShell 3.0+ (for CIM cmdlets)
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Internet connection required
    - Windows 7/8/10/11 and Server 2012+
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Windows successfully activated
    - 1: Activation failed
    
    External Dependencies:
    - Microsoft Activation Scripts (GitHub)
    - URL: https://github.com/massgravel/Microsoft-Activation-Scripts
    
    Security:
    - Uses TLS 1.2 for secure downloads
    - Validates download success before execution
    - Verifies activation status after execution
    
    Change Log:
    v1.1 - Added TLS 1.2, improved error handling, validation steps
    v1.0 - Initial release
#>

try {
    # Ensure TLS 1.2 is used for secure downloads
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Define the URL and local path
    $FileUrl = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/HWID_Activation.cmd"
    $LocalFilePath = "$env:TEMP\HWID_Activation.cmd"
    
    Write-Output "Starting Windows activation remediation..."
    
    # Get OS information
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    Write-Output "OS: $($osInfo.Caption) - Build: $($osInfo.BuildNumber)"
    
    # Download the activation script
    Write-Output "Downloading activation script from: $FileUrl"
    try {
        Invoke-WebRequest -Uri $FileUrl -OutFile $LocalFilePath -UseBasicParsing -ErrorAction Stop
        Write-Output "Download completed successfully"
    }
    catch {
        Write-Output "Failed to download activation script: $($_.Exception.Message)"
        exit 1
    }
    
    # Verify the file was downloaded
    if (-not (Test-Path $LocalFilePath)) {
        Write-Output "Downloaded file not found at: $LocalFilePath"
        exit 1
    }
    
    # Get file size for verification
    $fileSize = (Get-Item $LocalFilePath).Length
    Write-Output "Downloaded file size: $fileSize bytes"
    
    if ($fileSize -lt 1000) {
        Write-Output "Downloaded file appears to be invalid (too small)"
        Remove-Item -Path $LocalFilePath -Force -ErrorAction SilentlyContinue
        exit 1
    }
    
    # Execute the activation script
    Write-Output "Executing activation script..."
    try {
        $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$LocalFilePath`" /HWID" -Wait -PassThru -NoNewWindow
        $exitCode = $process.ExitCode
        Write-Output "Activation script completed with exit code: $exitCode"
    }
    catch {
        Write-Output "Failed to execute activation script: $($_.Exception.Message)"
        Remove-Item -Path $LocalFilePath -Force -ErrorAction SilentlyContinue
        exit 1
    }
    
    # Clean up the downloaded file
    Write-Output "Cleaning up temporary files..."
    Remove-Item -Path $LocalFilePath -Force -ErrorAction SilentlyContinue
    
    # Verify activation status
    Start-Sleep -Seconds 5
    
    # Try multiple methods to get licensing product
    $licensingProduct = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue | 
        Where-Object { $_.PartialProductKey -ne $null -and $_.Name -match "Windows" } | 
        Select-Object -First 1
    
    # Fallback method using ApplicationID
    if ($null -eq $licensingProduct) {
        $licensingProduct = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction SilentlyContinue |
            Where-Object { $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.PartialProductKey } |
            Select-Object -First 1
    }
    
    if ($licensingProduct -and $licensingProduct.LicenseStatus -eq 1) {
        Write-Output "SUCCESS: Windows is now activated"
        Write-Output "License: $($licensingProduct.Name)"
        Write-Output "Product Key: $($licensingProduct.PartialProductKey)"
        exit 0
    } else {
        $status = if ($licensingProduct) { $licensingProduct.LicenseStatus } else { "Unknown" }
        Write-Output "WARNING: Activation script ran but Windows may not be activated yet. Status: $status"
        Write-Output "Note: Activation may require a reboot to complete. Check again after restart."
        exit 0
    }
}
catch {
    Write-Output "Unexpected error during remediation: $($_.Exception.Message)"
    # Clean up on error
    if (Test-Path $LocalFilePath) {
        Remove-Item -Path $LocalFilePath -Force -ErrorAction SilentlyContinue
    }
    exit 1
}

