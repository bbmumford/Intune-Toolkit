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