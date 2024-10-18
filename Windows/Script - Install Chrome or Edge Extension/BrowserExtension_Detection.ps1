<# 
Version: 1.0 
Author: Brandon Miller-Mumford 
Script: DetectBrowserExtension.ps1 
Description: Detect Chrome or Edge Extensions 
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
