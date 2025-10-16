<#
.SYNOPSIS
    Helper module for Intune script completion tracking

.DESCRIPTION
    Provides standardized functions for tracking script execution completion
    using Windows Registry in Intune-managed environments.
    
    Standard Paths:
    - System Context: HKLM:\Software\IntuneDependencies
    - User Context:   HKCU:\Software\IntuneDependencies

.NOTES
    FileName:    IntuneScriptHelpers.psm1
    Author:      Brandon Miller-Mumford
    Created:     2025-10-17
    Version:     1.0
    
    Usage:
    Import-Module .\IntuneScriptHelpers.psm1
    
.EXAMPLE
    Import-Module .\IntuneScriptHelpers.psm1
    
    # Check if script completed
    if (Test-IntuneScriptCompletion -ScriptName "ZeroTierInstall" -SystemContext $true) {
        Write-Host "Already installed"
    }
    
    # Mark script as completed
    Set-IntuneScriptCompletion -ScriptName "ZeroTierInstall" -SystemContext $true -Version "1.0"
#>

function Test-IntuneScriptCompletion {
    <#
    .SYNOPSIS
        Tests if an Intune script has been marked as completed
    
    .DESCRIPTION
        Checks the standardized registry location to determine if a script
        has been executed and marked as complete.
    
    .PARAMETER ScriptName
        Name of the script to check (without "Completed" suffix)
    
    .PARAMETER SystemContext
        If $true, checks HKLM (System context). If $false, checks HKCU (User context)
        Default: $true
    
    .PARAMETER RequiredVersion
        Optional version string to check against. If specified, also validates version match.
    
    .OUTPUTS
        [bool] - $true if script is marked complete (and version matches if specified), $false otherwise
    
    .EXAMPLE
        Test-IntuneScriptCompletion -ScriptName "ZeroTierInstall" -SystemContext $true
        Returns $true if HKLM:\Software\IntuneDependencies\ZeroTierInstallCompleted = 1
    
    .EXAMPLE
        Test-IntuneScriptCompletion -ScriptName "DesktopInfo" -SystemContext $true -RequiredVersion "3.11.0"
        Returns $true only if completed AND version matches
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptName,
        
        [Parameter(Mandatory=$false)]
        [bool]$SystemContext = $true,
        
        [Parameter(Mandatory=$false)]
        [string]$RequiredVersion = $null
    )
    
    try {
        $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
        $RegPath = "$RegRoot\Software\IntuneDependencies"
        $RegName = "$($ScriptName)Completed"
        
        # Check if path exists
        if (-not (Test-Path $RegPath)) {
            Write-Verbose "Registry path does not exist: $RegPath"
            return $false
        }
        
        # Get the registry value
        $RegValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
        
        if ($null -eq $RegValue) {
            Write-Verbose "Registry value '$RegName' not found"
            return $false
        }
        
        # Check completion status
        $IsCompleted = ($RegValue.$RegName -eq 1) -or ($RegValue.$RegName -eq $true) -or ($RegValue.$RegName -eq "true")
        
        if (-not $IsCompleted) {
            Write-Verbose "Script not marked as completed"
            return $false
        }
        
        # If version checking is required
        if ($RequiredVersion) {
            $VersionValueName = "$($ScriptName)Version"
            $InstalledVersion = (Get-ItemProperty -Path $RegPath -Name $VersionValueName -ErrorAction SilentlyContinue).$VersionValueName
            
            if ($InstalledVersion -ne $RequiredVersion) {
                Write-Verbose "Version mismatch. Required: $RequiredVersion, Installed: $InstalledVersion"
                return $false
            }
        }
        
        Write-Verbose "Script marked as completed" + $(if ($RequiredVersion) { " with correct version" } else { "" })
        return $true
    }
    catch {
        Write-Warning "Error checking script completion: $($_.Exception.Message)"
        return $false
    }
}

function Set-IntuneScriptCompletion {
    <#
    .SYNOPSIS
        Marks an Intune script as completed in registry
    
    .DESCRIPTION
        Creates or updates the standardized registry entry to indicate a script
        has been executed successfully. Includes optional version and timestamp tracking.
    
    .PARAMETER ScriptName
        Name of the script to mark complete (without "Completed" suffix)
    
    .PARAMETER SystemContext
        If $true, writes to HKLM (System context). If $false, writes to HKCU (User context)
        Default: $true
    
    .PARAMETER Version
        Optional version string to track with the completion marker
    
    .PARAMETER AdditionalData
        Optional hashtable of additional key-value pairs to store
    
    .OUTPUTS
        [bool] - $true if successfully marked, $false otherwise
    
    .EXAMPLE
        Set-IntuneScriptCompletion -ScriptName "ZeroTierInstall" -SystemContext $true
        Creates HKLM:\Software\IntuneDependencies\ZeroTierInstallCompleted = 1
    
    .EXAMPLE
        Set-IntuneScriptCompletion -ScriptName "DesktopInfo" -SystemContext $true -Version "3.11.0"
        Creates completion marker with version tracking
    
    .EXAMPLE
        Set-IntuneScriptCompletion -ScriptName "MyScript" -SystemContext $true -AdditionalData @{ConfigPath="C:\Config\file.ini"}
        Creates completion marker with custom additional data
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptName,
        
        [Parameter(Mandatory=$false)]
        [bool]$SystemContext = $true,
        
        [Parameter(Mandatory=$false)]
        [string]$Version = $null,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$AdditionalData = @{}
    )
    
    try {
        $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
        $RegPath = "$RegRoot\Software\IntuneDependencies"
        
        # Create registry path if it doesn't exist
        if (-not (Test-Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
            Write-Verbose "Created registry path: $RegPath"
        }
        
        # Set completion marker
        $RegName = "$($ScriptName)Completed"
        Set-ItemProperty -Path $RegPath -Name $RegName -Value 1 -Type DWord -Force
        Write-Verbose "Set $RegName = 1"
        
        # Set timestamp
        $Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Timestamp" -Value $Timestamp -Type String -Force
        Write-Verbose "Set timestamp: $Timestamp"
        
        # Set version if provided
        if ($Version) {
            Set-ItemProperty -Path $RegPath -Name "$($ScriptName)Version" -Value $Version -Type String -Force
            Write-Verbose "Set version: $Version"
        }
        
        # Set additional data if provided
        foreach ($key in $AdditionalData.Keys) {
            $ValueName = "$($ScriptName)_$key"
            Set-ItemProperty -Path $RegPath -Name $ValueName -Value $AdditionalData[$key] -Type String -Force
            Write-Verbose "Set $ValueName = $($AdditionalData[$key])"
        }
        
        Write-Host "Successfully marked '$ScriptName' as completed in registry"
        return $true
    }
    catch {
        Write-Warning "Failed to mark script completion: $($_.Exception.Message)"
        return $false
    }
}

function Remove-IntuneScriptCompletion {
    <#
    .SYNOPSIS
        Removes completion marker for an Intune script
    
    .DESCRIPTION
        Removes the registry entries associated with a script's completion status.
        Useful for testing or forcing re-execution.
    
    .PARAMETER ScriptName
        Name of the script to clear (without "Completed" suffix)
    
    .PARAMETER SystemContext
        If $true, removes from HKLM (System context). If $false, removes from HKCU (User context)
        Default: $true
    
    .OUTPUTS
        [bool] - $true if successfully removed, $false otherwise
    
    .EXAMPLE
        Remove-IntuneScriptCompletion -ScriptName "ZeroTierInstall" -SystemContext $true
        Removes all ZeroTierInstall* entries from HKLM:\Software\IntuneDependencies
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptName,
        
        [Parameter(Mandatory=$false)]
        [bool]$SystemContext = $true
    )
    
    try {
        $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
        $RegPath = "$RegRoot\Software\IntuneDependencies"
        
        if (-not (Test-Path $RegPath)) {
            Write-Verbose "Registry path does not exist: $RegPath"
            return $true
        }
        
        # Get all properties
        $Properties = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
        
        if ($null -eq $Properties) {
            Write-Verbose "No properties found at $RegPath"
            return $true
        }
        
        # Find and remove all properties starting with ScriptName
        $RemovedCount = 0
        $Properties.PSObject.Properties | Where-Object { $_.Name -like "$ScriptName*" } | ForEach-Object {
            $PropName = $_.Name
            
            if ($PSCmdlet.ShouldProcess("$RegPath\$PropName", "Remove registry value")) {
                Remove-ItemProperty -Path $RegPath -Name $PropName -ErrorAction SilentlyContinue
                Write-Verbose "Removed property: $PropName"
                $RemovedCount++
            }
        }
        
        Write-Host "Removed $RemovedCount registry value(s) for '$ScriptName'"
        return $true
    }
    catch {
        Write-Warning "Failed to remove script completion markers: $($_.Exception.Message)"
        return $false
    }
}

function Get-IntuneScriptCompletionInfo {
    <#
    .SYNOPSIS
        Retrieves detailed completion information for an Intune script
    
    .DESCRIPTION
        Gets all registry values associated with a script's completion status,
        including version, timestamp, and any additional data.
    
    .PARAMETER ScriptName
        Name of the script to query (without "Completed" suffix)
    
    .PARAMETER SystemContext
        If $true, queries HKLM (System context). If $false, queries HKCU (User context)
        Default: $true
    
    .OUTPUTS
        [PSCustomObject] - Object containing completion details, or $null if not found
    
    .EXAMPLE
        Get-IntuneScriptCompletionInfo -ScriptName "ZeroTierInstall" -SystemContext $true
        Returns object with Completed, Version, Timestamp properties
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptName,
        
        [Parameter(Mandatory=$false)]
        [bool]$SystemContext = $true
    )
    
    try {
        $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
        $RegPath = "$RegRoot\Software\IntuneDependencies"
        
        if (-not (Test-Path $RegPath)) {
            Write-Verbose "Registry path does not exist: $RegPath"
            return $null
        }
        
        $Properties = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
        
        if ($null -eq $Properties) {
            return $null
        }
        
        # Build result object
        $Result = [PSCustomObject]@{
            ScriptName    = $ScriptName
            Context       = if ($SystemContext) { "System (HKLM)" } else { "User (HKCU)" }
            RegistryPath  = $RegPath
        }
        
        # Add all properties that start with ScriptName
        $Properties.PSObject.Properties | Where-Object { $_.Name -like "$ScriptName*" } | ForEach-Object {
            $PropName = $_.Name -replace "^$ScriptName", ""
            $Result | Add-Member -MemberType NoteProperty -Name $PropName -Value $_.Value
        }
        
        # Check if completed
        if ($null -eq $Result.Completed) {
            return $null
        }
        
        return $Result
    }
    catch {
        Write-Warning "Error retrieving script completion info: $($_.Exception.Message)"
        return $null
    }
}

function Get-AllIntuneScriptCompletions {
    <#
    .SYNOPSIS
        Lists all completed Intune scripts
    
    .DESCRIPTION
        Retrieves completion status for all scripts tracked in the IntuneDependencies registry location.
    
    .PARAMETER SystemContext
        If $true, queries HKLM (System context). If $false, queries HKCU (User context)
        Default: $true
    
    .OUTPUTS
        [Array] - Array of PSCustomObjects containing completion information
    
    .EXAMPLE
        Get-AllIntuneScriptCompletions -SystemContext $true
        Lists all completed scripts in system context
    #>
    [CmdletBinding()]
    [OutputType([Array])]
    param(
        [Parameter(Mandatory=$false)]
        [bool]$SystemContext = $true
    )
    
    try {
        $RegRoot = if ($SystemContext) { "HKLM:" } else { "HKCU:" }
        $RegPath = "$RegRoot\Software\IntuneDependencies"
        
        if (-not (Test-Path $RegPath)) {
            Write-Verbose "Registry path does not exist: $RegPath"
            return @()
        }
        
        $Properties = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
        
        if ($null -eq $Properties) {
            return @()
        }
        
        # Find all "Completed" properties
        $CompletedScripts = $Properties.PSObject.Properties | 
            Where-Object { $_.Name -like "*Completed" -and $_.Name -notlike "PS*" } |
            ForEach-Object {
                $ScriptName = $_.Name -replace "Completed$", ""
                Get-IntuneScriptCompletionInfo -ScriptName $ScriptName -SystemContext $SystemContext
            } |
            Where-Object { $null -ne $_ }
        
        return $CompletedScripts
    }
    catch {
        Write-Warning "Error retrieving all completions: $($_.Exception.Message)"
        return @()
    }
}

# Export module functions
Export-ModuleMember -Function Test-IntuneScriptCompletion, `
                              Set-IntuneScriptCompletion, `
                              Remove-IntuneScriptCompletion, `
                              Get-IntuneScriptCompletionInfo, `
                              Get-AllIntuneScriptCompletions
