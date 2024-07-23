<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Configure-CitrixWorkspace_Remediation.ps1
Description: 
Version 1.0: Init
Run as: User
Context: 64 Bit
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