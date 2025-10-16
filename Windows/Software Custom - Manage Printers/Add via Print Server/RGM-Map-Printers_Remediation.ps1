<#
.SYNOPSIS
    Maps network printers from print server

.DESCRIPTION
    Connects to a specified print server and maps network printers to the
    user's profile. Supports multiple printer shares and optional removal
    of existing printer connections.
    
    Used for enterprise printer deployment via Intune Proactive Remediation.
    
    Parameters:
    - $PrintServerFQDN: Fully qualified domain name of print server (required)
    - $PrinterShareNames: Array of printer share names to map (required)
    - $RemoveFirst: Optional switch to remove existing printers before mapping
    - $PrinterNamesToRemove: Array of printer names to remove (optional)
    
.NOTES
    FileName:    RGM-Map-Printers_Remediation.ps1
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
    - 0: Remediation successful (printers mapped)
    - 1: Remediation failed
    
    Usage:
    RGM-Map-Printers_Remediation.ps1 -PrintServerFQDN "printserver.domain.com" -PrinterShareNames @("Printer1","Printer2")
    
    RGM-Map-Printers_Remediation.ps1 -PrintServerFQDN "printserver.domain.com" -PrinterShareNames @("Printer1") -RemoveFirst -PrinterNamesToRemove @("OldPrinter")
    
    Configuration:
    - Customize printer share names for each location
    - Set print server FQDN
    - Use RemoveFirst to clean up old printers
    
    Change Log:
    v1.0 - Initial release
#>

Param
(
[Parameter(Mandatory=$true)]
[ValidateScript({If($_ -like "*.*"){$true}Else{Throw "$_ is not an FQDN. Please enter a FQDN."}})]
[string]
$PrintServerFQDN
,
[Parameter(Mandatory=$true)]
[string[]]
$PrinterShareNames=@()
,
[Parameter(Mandatory=$False)]
[switch]
$RemoveFirst
,
[Parameter(Mandatory=$False)]
[switch]
$RemoveOnly
)

# normalize the Print server FQDN
If ($PrintServerFQDN -notlike "\\*") {$PrintServerFQDN = "\\" + $PrintServerFQDN}

# Get the non FQDN name of the print server from the FQDN
$PrintServerName = $PrintServerFQDN.Split(".")[0]

# Remove printers
If (($RemoveFirst -eq $true) -Or ($RemoveOnly -eq $true)){
    Try {
        Foreach ($Printer in $PrinterShareNames){
            # Generate printer names
            $PrinterNameFQDN = $PrintServerFQDN + "\" + $Printer
            $PrinterName = $PrintServerName + "\" + $Printer

            # Remove Printer if it exists
            If (get-printer -Name $PrinterNameFQDN -ErrorAction SilentlyContinue) {Remove-Printer -Name $PrinterNameFQDN}
            If (get-printer -Name $PrinterName -ErrorAction SilentlyContinue) {Remove-Printer -Name $PrinterName}
        }
    }
    Catch {
        $ErrorMsg = $_.Exception.Message
        Write-Host "Printer removal error: $ErrorMsg"
    }
}

# (Re)Add printer
If ($RemoveOnly -eq $false){
    Try {
        Foreach ($Printer in $PrinterShareNames){
            # Generate correct printer name for (re)adding
            $PrinterNameFQDN = $PrintServerFQDN + "\" + $Printer

            # (Re)Add printer
            Add-Printer -ConnectionName $PrinterNameFQDN
        }
    }
    Catch {
        $ErrorMsg = $_.Exception.Message
        Write-Host "Printer add error: $ErrorMsg"
    }
}