<#
.SYNOPSIS
    Detects if Drouin office printers are installed

.DESCRIPTION
    Checks if all required Drouin office network printers are installed on
    the device.
    
    Validates presence of all five Drouin printers (Front BW, Colour, BW,
    Back BW, Back Colour).
    
.NOTES
    FileName:    RGM-Map-Printers-Drouin_Detection.ps1
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
    - 0: Compliant (all Drouin printers installed)
    - 1: Non-Compliant (one or more printers missing)
    
    Configuration:
    - Drouin office printers:
      * \\RGM-DRN1\Drouin_Back_B&W
      * \\RGM-DRN1\Drouin_Back_Colour
      * \\RGM-DRN1\Drouin_Front_BW
      * \\RGM-DRN1\Drouin_Colour
      * \\RGM-DRN1\Drouin_BW
    
    Change Log:
    v1.0 - Initial release
#>

# Set variable with printer names
$Printers = @("\\RGM-DRN1\Drouin_Back_B&W","\\RGM-DRN1\Drouin_Back_Colour","\\RGM-DRN1\Drouin_Front_BW","\\RGM-DRN1\Drouin_Colour","\\RGM-DRN1\Drouin_BW")

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