<#
.SYNOPSIS
    Detects if Traralgon office printers are installed

.DESCRIPTION
    Checks if all required Traralgon office network printers are installed
    on the device.
    
    Validates presence of all four Traralgon printers (Front/Back BW/Colour).
    
.NOTES
    FileName:    RGM-Map-Printers-Traralgon_Detection.ps1
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
    - 0: Compliant (all Traralgon printers installed)
    - 1: Non-Compliant (one or more printers missing)
    
    Configuration:
    - Traralgon office printers:
      * \\RGM-TGN1\Traralgon_Back_BW
      * \\RGM-TGN1\Traralgon_Back_Colour
      * \\RGM-TGN1\Traralgon_Front_BW
      * \\RGM-TGN1\Traralgon_Front_Colour
    
    Change Log:
    v1.0 - Initial release
#>

# Set variable with printer names
$Printers = @("\\RGM-TGN1\Traralgon_Back_BW","\\RGM-TGN1\Traralgon_Back_Colour","\\RGM-TGN1\Traralgon_Front_BW","\\RGM-TGN1\Traralgon_Front_Colour")

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