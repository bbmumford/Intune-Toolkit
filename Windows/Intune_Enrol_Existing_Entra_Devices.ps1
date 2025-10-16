<#
.SYNOPSIS
    Enrolls existing Entra ID (Azure AD) joined devices into Intune

.DESCRIPTION
    Configures MDM enrollment URLs in the registry to enable existing
    Entra ID joined devices to automatically enroll in Microsoft Intune.
    
    Reads the Tenant ID from CloudDomainJoin registry keys and sets the
    appropriate MDM enrollment URLs for Intune management.
    
.NOTES
    FileName:    Intune_Enrol_Existing_Entra_Devices.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10 1809+ or Windows 11
    - Device must be Entra ID joined
    
    Exit Codes:
    - 0: Enrollment configuration successful
    - 1001: Tenant ID not found (device not Entra joined)
    
    Registry Path:
    - HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\{TenantID}
    
    Impact:
    - Enables MDM auto-enrollment for Entra joined devices
    - Device will enroll in Intune on next Group Policy update
    - No user interaction required
    
    Usage:
    Use with Intune Win32 app or Configuration Script to enroll existing
    Entra joined devices that are not yet managed.
    
    Change Log:
    v1.0 - Initial release
#>

# Set MDM Enrollment URL's
$key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*'

try{
    $keyinfo = Get-Item "HKLM:\$key"
}
catch{
    Write-Host "Tenant ID is not found!"
    exit 1001
}

$url = $keyinfo.name
$url = $url.Split("\")[-1]
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$url"
if(!(Test-Path $path)){
    Write-Host "KEY $path not found!"
    exit 1001
}else{
    try{
        Get-ItemProperty $path -Name MdmEnrollmentUrl
    }
    catch{
        Write_Host "MDM Enrollment registry keys not found. Registering now..."
        New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
        New-ItemProperty -LiteralPath $path -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
        New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;
    }
    finally{
    # Trigger AutoEnroll with the deviceenroller
        try{
            C:\Windows\system32\deviceenroller.exe /c /AutoEnrollMDM
            Write-Host "Device is performing the MDM enrollment!"
           exit 0
        }
        catch{
            Write-Host "Something went wrong (C:\Windows\system32\deviceenroller.exe)"
           exit 1001          
        }

    }
}
exit 0