<#
.SYNOPSIS
    Adds network resource credentials to Windows Credential Manager

.DESCRIPTION
    Stores network credentials (username/password) in Windows Credential
    Manager for accessing network resources like file shares, servers, or
    remote systems.
    
    Credentials are encrypted and stored per-user in Credential Manager,
    enabling automatic authentication to specified network targets.
    
    Parameters:
    - $target: Network resource (UNC path, server name, or IP)
    - $username: Username for authentication
    - $password: Password for authentication
    
.NOTES
    FileName:    AddResoureCredentials.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: System
    - Context: 64 Bit
    - Windows 7/8/10/11
    
    Exit Codes:
    - 0: Credentials added successfully
    - 1: Failed to add credentials
    
    Usage:
    powershell.exe -File AddResoureCredentials.ps1 -target "\\server\share" -username "domain\user" -password "P@ssw0rd"
    
    Security/Privacy:
    - Credentials stored encrypted in Windows Credential Manager
    - Only accessible by the user who created them
    - Consider using Group Policy Preferences for enterprise deployment
    
    Change Log:
    v1.0 - Initial release
#>

# Variables
param (
    [Parameter(Mandatory=$true)]
    [string]$target,

    [Parameter(Mandatory=$true)]
    [string]$username,

    [Parameter(Mandatory=$true)]
    [string]$password
)

# Function to check if the credentials exist
function Check-Credential {
    try {
        $cmdkey = cmdkey /list | Select-String $target
        return $cmdkey -ne $null
    } catch {
        Write-Error "Error checking credentials: $_"
        return $false
		exit 1
    }
}

# Function to add the credentials
function Add-Credential {
    try {
        cmdkey /add:$target /user:$username /pass:$password
        Write-Output "Credentials added for $target."
		exit 0
    } catch {
        Write-Error "Error adding credentials: $_"
		exit 1
    }
}

# Main execution
try {
    if (-not (Check-Credential)) {
        Add-Credential
    } else {
        Write-Output "Credentials for $target already exist."
		exit 0
    }
} catch {
    Write-Error "An unexpected error occurred: $_"
	exit 1
}