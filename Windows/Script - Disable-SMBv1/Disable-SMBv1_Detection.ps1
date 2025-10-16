<#
.SYNOPSIS
    Detects if SMBv1 protocol is disabled on the system

.DESCRIPTION
    Checks if the insecure SMBv1 (Server Message Block version 1) protocol is disabled
    using the Get-SmbServerConfiguration cmdlet.
    
    SMBv1 should be disabled for security compliance as it's vulnerable to exploits
    like WannaCry ransomware and is deprecated by Microsoft.
    
.NOTES
    FileName:    Disable-SMBv1_Detection.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 3.0+ (for Get-SmbServerConfiguration cmdlet)
    - Run as: System
    - Context: 64 Bit
    - Windows 8/10/11 and Server 2012+
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Compliant (SMBv1 is disabled)
    - 1: Non-Compliant (SMBv1 is enabled - triggers remediation)
    
    Security:
    - SMBv1 is a legacy protocol with known security vulnerabilities
    - Microsoft recommends disabling SMBv1 on all systems
    
    Change Log:
    v1.0 - Initial release
#>
$smbv1 = get-smbserverconfiguration | Select-Object -ExpandProperty EnableSMB1Protocol
if ($smbv1 -eq $false) {
    write-host "SMBv1 is disabled"
    exit 0
}
else {
    write-host "SMBv1 is enabled"
    exit 1
}