<#
.SYNOPSIS
    Disables the insecure SMBv1 protocol for security compliance

.DESCRIPTION
    Disables SMBv1 (Server Message Block version 1) protocol using the
    Set-SmbServerConfiguration cmdlet with -EnableSMB1Protocol 0.
    
    SMBv1 is a legacy protocol with known security vulnerabilities and should be disabled
    to protect against exploits like WannaCry ransomware. Microsoft recommends disabling
    SMBv1 on all modern Windows systems.
    
.NOTES
    FileName:    Disable-SMBv1_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 3.0+ (for Set-SmbServerConfiguration cmdlet)
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 8/10/11 and Server 2012+
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (SMBv1 disabled)
    - 1: Remediation failed
    
    Security:
    - SMBv1 protocol is vulnerable to remote code execution attacks
    - Disabling SMBv1 is a Microsoft security best practice
    - May require system restart to fully take effect
    
    Change Log:
    v1.0 - Initial release
#>
Set-SmbServerConfiguration -EnableSMB1Protocol 0