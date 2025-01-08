<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Configure-CitrixWorkspace_Detection.ps1
Description: 
Version 1.0: Init
Run as: User
Context: 64 Bit
#> 
#region Define registry keys to validate here
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
    REG_DWORD     = [Microsoft.Win32.RegistryValueKind]::DWord
    REG_SZ        = [Microsoft.Win32.RegistryValueKind]::String
    REG_QWORD     = [Microsoft.Win32.RegistryValueKind]::QWord
    REG_BINARY    = [Microsoft.Win32.RegistryValueKind]::Binary
    REG_MULTI_SZ  = [Microsoft.Win32.RegistryValueKind]::MultiString
    REG_EXPAND_SZ = [Microsoft.Win32.RegistryValueKind]::ExpandString
}
[Flags()] enum RegKeyError {
    None  = 0
    Path  = 1
    Name  = 2
    Type  = 4
    Value = 8
}
#endregion

#region Check if registry keys are set correctly
$KeyErrors = @()
$Output = ""
Foreach ($reg in $RegistrySettingsToValidate) {
    [RegKeyError]$CurrentKeyError = 15

    $DesiredPath          = "$($reg.Hive)$($reg.Key)"
    $DesiredName          = $reg.Name
    $DesiredType          = $RegTypeMap[$reg.Type]
    $DesiredValue         = $reg.Value

    # Check if the registry key path exists
    If (Test-Path -Path $DesiredPath) {
        $CurrentKeyError -= [RegKeyError]::Path

        # Check if the registry value exists
        If (Get-ItemProperty -Path $DesiredPath -Name $DesiredName -ErrorAction SilentlyContinue) {
            $CurrentKeyError -= [RegKeyError]::Name

            # Check if the registry value type is correct
            If ($(Get-Item -Path $DesiredPath).GetValueKind($DesiredName) -eq $DesiredType) {
                $CurrentKeyError -= [RegKeyError]::Type
                
                # Check if the registry value is correct
                If ($((Get-ItemProperty -Path $DesiredPath -Name $DesiredName).$DesiredName) -eq $DesiredValue) {
                    $CurrentKeyError -= [RegKeyError]::Value
                    # Write-Host "[$DesiredPath | $DesiredName | $RetTypeRegistry | $DesiredValue] exists and is correct"
                } 
            }
        }
    }
    $KeyErrors += $CurrentKeyError
    $Output += " | $DesiredName ErrorCode = $CurrentKeyError"
}
#endregion

#region Check if all registry keys are correct
if (($KeyErrors.value__ | Measure-Object -Sum).Sum -eq 0) {
    $ExitCode = 0
}
else {
    $ExitCode = 1
}
#endregion

Write-Output $Output.TrimStart(" |")
Exit $ExitCode