<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: AddResourceCredentials.ps1
Description: details set via command line arguments
Release notes:
Version 1.0: Init
Run as: System
Context: 64 Bit
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