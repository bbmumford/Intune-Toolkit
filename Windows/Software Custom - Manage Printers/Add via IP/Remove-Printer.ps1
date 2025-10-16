<#
.SYNOPSIS
    Removes a network printer by name

.DESCRIPTION
    Removes an installed network printer from the system using the printer's
    display name.
    
    Simple utility for printer removal in enterprise environments.
    
    Parameters:
    - $PrinterName: Display name of the printer to remove (required)
    
.NOTES
    FileName:    Remove-Printer.ps1
    Author:      Ben Whitmore
    Created:     2021-12-31
    Modified:    2025-10-17
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System or User (User context preferred)
    - Context: 64 Bit
    - Windows 10/11
    
    Exit Codes:
    - 0: Printer removed successfully
    - 1: Removal failed
    
    Usage:
    powershell.exe -executionpolicy bypass -file .\Remove-Printer.ps1 -PrinterName "Canon Printer Upstairs"
    
    Example:
    .\Remove-Printer.ps1 -PrinterName "Canon Printer Upstairs"
    
    Change Log:
    v1.0 - Initial release
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)]
    [String]$PrinterName
)

Try {
    #Remove Printer
    $PrinterExist = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
    if ($PrinterExist) {
        Remove-Printer -Name $PrinterName -Confirm:$false
    }
}
Catch {
    Write-Warning "Error removing Printer"
    Write-Warning "$($_.Exception.Message)"
}