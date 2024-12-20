<#
Version: 3.1
Author: 
- Brandon Miller-Mumford
Script: Application_Downloader&Installer.ps1
Description:
Version 3.1: Preserve the file type based on download URL or HTTP headers
Run as: System/User
Context: 64 Bit
#>

param (
    [string]$DownloadUrl,
    [string]$InstallerArgs
)

# Log file for debugging
$logFile = "$env:TEMP\Application_Installer.log"

function Log-Message {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$type] $message"
    Write-Output $logEntry
    $logEntry | Out-File -Append -FilePath $logFile
}

# Function to get the file extension from URL or HTTP headers
function Get-FileExtension {
    param (
        [string]$url
    )

    # Extract extension from URL if available
    if ($url -match "\.\w+$") {
        return ($url -split "\.")[-1]
    }

    # If no extension in URL, attempt to get it from HTTP headers
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing
        if ($response.Headers["Content-Type"] -match "application/x-msi") {
            return "msi"
        } elseif ($response.Headers["Content-Type"] -match "application/x-executable") {
            return "exe"
        }
    } catch {
        Log-Message "Unable to determine file extension from HTTP headers: $_" "WARN"
    }

    # Default to .exe if all else fails
    return "exe"
}

# Function to download the file
function Download-FileAsync {
    param (
        [string]$url,
        [string]$output
    )

    try {
        Log-Message "Downloading $url to $output"
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        Log-Message "Download complete"
    } catch {
        Log-Message "Failed to download file: $_" "ERROR"
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
        # Validate file type
        if ($installerPath -notmatch '\.(exe|msi)$') {
            Log-Message "Invalid installer file type: $installerPath" "ERROR"
            exit 1
        }

        Log-Message "Verifying installer file exists: $installerPath"
        if (-not (Test-Path $installerPath)) {
            Log-Message "Installer file does not exist at $installerPath" "ERROR"
            exit 1
        }

        # Run the installer
        if ($installerPath -like "*.msi") {
            Log-Message "Starting silent MSI installation of $installerPath with arguments $arguments"
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" $arguments" -Wait
        } elseif ($installerPath -like "*.exe") {
            Log-Message "Starting silent EXE installation of $installerPath with arguments $arguments"
            Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait
        } else {
            Log-Message "The installer format is not supported: $installerPath" "ERROR"
            exit 1
        }
        Log-Message "Installation complete"
    } catch {
        Log-Message "Installation failed: $_" "ERROR"
        exit 1
    }
}

# Main script logic
try {
    # Get file extension dynamically
    $fileExtension = Get-FileExtension -url $DownloadUrl
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $installerPath = "$env:TEMP\installer_$timestamp.$fileExtension"

    # Download the file
    Download-FileAsync -url $DownloadUrl -output $installerPath

    # Install the application with additional arguments
    Install-Application -installerPath $installerPath -arguments $InstallerArgs

    # Clean up
    Log-Message "Cleaning up temporary files"
    Remove-Item -Path $installerPath -Force
    Log-Message "Cleanup complete"
} catch {
    Log-Message "Script execution failed: $_" "ERROR"
    exit 1
}
