<#
.SYNOPSIS
    Detects if Moe office printers are installed

.DESCRIPTION
    Checks if all required Moe office network printers are installed on
    the device.
    
    Validates presence of all four Moe printers (Front/Back BW/Colour).
    
.NOTES
    FileName:    RGM-Map-Printers-Moe_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: User
    - Context: 64 Bit
    - Windows 10/11
    - Network connectivity to print server
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (all Moe printers installed)
    - 1: Non-Compliant (one or more printers missing)
    
    Configuration:
    - Moe office printers:
      * \\RGM-MOE1\Moe_Back_B&W
      * \\RGM-MOE1\Moe_Back_Colour
      * \\RGM-MOE1\Moe_Front_B&W
      * \\RGM-MOE1\Moe_Front_Colour
    
    Change Log:
    v1.0 - Initial release
#>

# Set variable with printer names
$Printers = @("\\RGM-MOE1\Moe_Back_B&W","\\RGM-MOE1\Moe_Back_Colour","\\RGM-MOE1\Moe_Front_B&W","\\RGM-MOE1\Moe_Front_Colour")

# Check if printers are installed
Try{
    Foreach($Printer in $Printers){
        # Throw error is printer doesn't exist
        If (!(Get-Printer -Name $Printer -ErrorAction SilentlyContinue)){
            Write-Host "$Printer not found"
            Exit 1
        }
    }
    # If no errors exit with success message and exit code
    Write-Host "All printers detected"
    Exit 0
}
Catch {
    $ErrorMsg = $_.Exception.Message
    Write-Host "Printer detection error: $ErrorMsg"
    Exit 1
}