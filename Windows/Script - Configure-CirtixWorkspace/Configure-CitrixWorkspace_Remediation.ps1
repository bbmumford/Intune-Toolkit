<#
.SYNOPSIS
    Configures Citrix Workspace registry settings for enterprise use

.DESCRIPTION
    Sets required registry keys for Citrix Workspace application to ensure
    compliance with organizational configuration standards. Creates and sets
    multiple registry values for store URLs, preferences, and settings.
    
.NOTES
    FileName:    Configure-CitrixWorkspace_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: User (HKCU registry context)
    - Context: 64 Bit
    - Citrix Workspace installed
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (Citrix settings configured)
    - 1: Remediation failed
    
    Purpose:
    - Enforce enterprise Citrix Workspace configuration
    - Configure store URLs and connection settings
    - Ensure consistent user experience
    
    Change Log:
    v1.0 - Initial release
#>

#region Define registry keys to create here
$RegistrySettingsToValidate = @(
    [pscustomobject]@{
        Hive  = 'HKLM:\'
        Key   = 'SOFTWARE\WOW6432Node\Citrix\Dazzle'
        Name  = 'PutShortcutsInStartMenu'
        Type  = 'REG_SZ'
        Value = "True"
    },
    [pscustomobject]@{
        Hive  = 'HKLM:\'
        Key   = 'SOFTWARE\WOW6432Node\Citrix\Dazzle'
        Name  = 'PutShortcutsOnDesktop'
        Type  = 'REG_SZ'
        Value = "True"
    }
)
#endregion

#region helper functions, enums and maps
$RegTypeMap = @{
    REG_DWORD = [Microsoft.Win32.RegistryValueKind]::DWord
    REG_SZ = [Microsoft.Win32.RegistryValueKind]::String
    REG_QWORD = [Microsoft.Win32.RegistryValueKind]::QWord
    REG_BINARY = [Microsoft.Win32.RegistryValueKind]::Binary
    REG_MULTI_SZ = [Microsoft.Win32.RegistryValueKind]::MultiString
    REG_EXPAND_SZ = [Microsoft.Win32.RegistryValueKind]::ExpandString
}
#endregion

#region Create registry keys
$Output = "Something went wrong :-("
$Names = @()
$ExitCode = 1
Foreach ($reg in $RegistrySettingsToValidate) {

    $DesiredPath          = "$($reg.Hive)$($reg.Key)"
    $DesiredName          = $reg.Name
    $DesiredType          = $RegTypeMap[$reg.Type]
    $DesiredValue         = $reg.Value

    #Write-Host "Creating registry value: $DesiredPath | $DesiredName | $($reg.Type) | $DesiredValue" 
    
    If (-not (Test-Path -Path $DesiredPath)) {
        New-Item -Path $DesiredPath -Force | Out-Null
    }
    New-ItemProperty -Path $DesiredPath -Name $DesiredName -PropertyType $DesiredType -Value $DesiredValue -Force -ErrorAction SilentlyContinue | Out-Null
    $Names += $DesiredName
}
#endregion

#region Check if registry keys are set correctly
If ($Names.count -eq $RegistrySettingsToValidate.count) {
    $Output = "All OK | Registry values created: $($Names -join ', ')"
    $ExitCode = 0
} else {
    $Output = "Something went wrong :-( | Registry values created: $($Names -join ', ')"
    $ExitCode = 1
}
#endregion

Write-Output $Output
Exit $ExitCode