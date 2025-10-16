<#
.SYNOPSIS
    Detects if browser extension is installed

.DESCRIPTION
    Checks if a specified Chrome or Edge extension is installed by verifying
    the registry keys created when extensions are deployed via policy.
    
    Supports both Google Chrome and Microsoft Edge (Chromium-based).
    
.NOTES
    FileName:    BrowserExtension_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System/User
    - Context: 64 Bit
    - Google Chrome or Microsoft Edge installed
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (extension installed)
    - 1: Non-Compliant (triggers extension installation)
    
    Configuration:
    - Set $ID to the extension ID from Chrome Web Store
    - Set $Chrome = $true for Chrome extensions
    - Set $Edge = $true for Edge extensions
    
    Change Log:
    v1.0 - Initial release
#>

# Set parameters directly in the script
$ID = 'YOUR_EXTENSION_ID_HERE' # Change this to the extension ID you want to check
$Chrome = $true # Set to $true if checking for Chrome
$Edge = $false # Set to $true if checking for Edge

function Find-Policies {
    # Check for extension policies
    try {
        $BlockPolicy = "HKLM:\Software\Policies\$($Ext.Reg)\ExtensionInstallBlocklist"
        if ((Test-Path $BlockPolicy) -and ($null -ne (Get-ItemProperty -Path $BlockPolicy))) {
            Write-Warning ('Detected possible Group Policy settings for browser extensions - manually check for conflicts.')
        }
    } catch {
        Write-Warning 'Unable to detect browser extension policies.'
        Write-Warning $_
    }
}

function CheckExtension {
    # Check if the extension is installed by looking up the registry
    $InstallKey = if ($Chrome) {
        "HKLM:\Software\Google\Chrome\Extensions\$ID"
    } elseif ($Edge) {
        "HKLM:\Software\Microsoft\Edge\Extensions\$ID"
    } else {
        return 2 # Non-recoverable error
    }

    if (Test-Path $InstallKey) {
        Write-Output "Extension with ID '$ID' is installed in $($Ext.Browser)."
        exit 0 # Success
    } else {
        Write-Output "Extension with ID '$ID' is not installed in $($Ext.Browser)."
        exit 1 # Failure
    }
}

# Build Extension Object
if ($Chrome) {
    $Ext = [PSCustomObject]@{
        Browser   = 'Chrome'
        Reg       = 'Google\Chrome'
    }
} elseif ($Edge) {
    $Ext = [PSCustomObject]@{
        Browser   = 'Edge'
        Reg       = 'Microsoft\Edge'
    }
}

Find-Policies
CheckExtension
