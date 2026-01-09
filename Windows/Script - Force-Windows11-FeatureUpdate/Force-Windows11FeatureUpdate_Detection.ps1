<#
.SYNOPSIS
    Detects if device needs Windows 11 feature update

.DESCRIPTION
    Checks if the device is running an outdated Windows 11 build and requires
    a feature update. This script is designed for Intune Proactive Remediation.
    
    Detection Logic:
    - Checks current Windows build number against minimum required
    - Detects Windows Update corruption or stuck updates
    - Identifies devices that haven't updated in specified days
    
.NOTES
    FileName:    Force-Windows11FeatureUpdate_Detection.ps1
    Author:      
    Created:     2026-01-08
    Modified:    2026-01-08
    Version:     1.0
    
    Requirements:
    - PowerShell 5.1+
    - Run as: System
    - Context: 64 Bit
    
    Exit Codes:
    - 0: Compliant (no remediation needed)
    - 1: Non-compliant (remediation required)
    
    Change Log:
    v1.0 - Initial release
#>

#region Configuration
# Minimum required Windows 11 build number
# Windows 11 23H2 = 22631
# Windows 11 24H2 = 26100
# Adjust this value to your organization's requirements
$MinimumBuild = 22631

# Maximum days since last successful update
$MaxDaysSinceUpdate = 60

# Check for Windows Update service issues
$CheckUpdateHealth = $true
#endregion

#region Functions
function Get-WindowsBuildInfo {
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
    $Build = [int](Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentBuild).CurrentBuild
    $UBR = [int](Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name UBR).UBR
    $DisplayVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
    
    return @{
        Caption        = $OS.Caption
        Build          = $Build
        UBR            = $UBR
        FullBuild      = "$Build.$UBR"
        DisplayVersion = $DisplayVersion
    }
}

function Test-WindowsUpdateHealth {
    $Issues = @()
    
    # Check Windows Update service
    $WUService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($WUService.Status -ne 'Running' -and $WUService.StartType -ne 'Manual') {
        $Issues += "Windows Update service not running"
    }
    
    # Check for pending reboot that's been pending too long
    $RebootPending = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    if ($RebootPending) {
        $RebootKey = Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction SilentlyContinue
        if ($RebootKey) {
            $KeyDate = $RebootKey.GetValue("RebootRequired")
            $Issues += "Reboot pending for Windows Update"
        }
    }
    
    # Check component store health
    $CBSLog = "$env:SystemRoot\Logs\CBS\CBS.log"
    if (Test-Path $CBSLog) {
        $RecentErrors = Get-Content $CBSLog -Tail 100 -ErrorAction SilentlyContinue | 
            Where-Object { $_ -match "ERROR|FAIL" -and $_ -match "0x8" }
        if ($RecentErrors.Count -gt 10) {
            $Issues += "Component store may have corruption (multiple CBS errors)"
        }
    }
    
    # Check for stuck downloads in SoftwareDistribution
    $DownloadPath = "$env:SystemRoot\SoftwareDistribution\Download"
    if (Test-Path $DownloadPath) {
        $StuckFiles = Get-ChildItem -Path $DownloadPath -Recurse -File -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
        if ($StuckFiles.Count -gt 50) {
            $Issues += "Stale files in Windows Update download cache"
        }
    }
    
    return $Issues
}

function Get-LastSuccessfulUpdate {
    try {
        $Session = New-Object -ComObject Microsoft.Update.Session
        $Searcher = $Session.CreateUpdateSearcher()
        $History = $Searcher.QueryHistory(0, 50)
        
        $LastSuccess = $History | 
            Where-Object { $_.ResultCode -eq 2 } | # 2 = Succeeded
            Sort-Object Date -Descending |
            Select-Object -First 1
        
        if ($LastSuccess) {
            return $LastSuccess.Date
        }
    }
    catch {
        # Fallback to registry
        $InstallDate = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallDate -ErrorAction SilentlyContinue).InstallDate
        if ($InstallDate) {
            return (Get-Date "1970-01-01").AddSeconds($InstallDate)
        }
    }
    
    return $null
}
#endregion

#region Main Detection
try {
    Write-Output "=== Windows 11 Feature Update Detection ==="
    
    # Get current build info
    $BuildInfo = Get-WindowsBuildInfo
    Write-Output "Current OS: $($BuildInfo.Caption)"
    Write-Output "Current Build: $($BuildInfo.FullBuild) ($($BuildInfo.DisplayVersion))"
    Write-Output "Minimum Required Build: $MinimumBuild"
    
    $RequiresRemediation = $false
    $Reasons = @()
    
    # Check 1: Build version
    if ($BuildInfo.Build -lt $MinimumBuild) {
        $RequiresRemediation = $true
        $Reasons += "Build $($BuildInfo.Build) is below minimum required ($MinimumBuild)"
    }
    else {
        Write-Output "BUILD CHECK: PASSED - Current build meets minimum requirements"
    }
    
    # Check 2: Windows Update health
    if ($CheckUpdateHealth) {
        $HealthIssues = Test-WindowsUpdateHealth
        if ($HealthIssues.Count -gt 0) {
            $RequiresRemediation = $true
            foreach ($Issue in $HealthIssues) {
                $Reasons += "Update Health Issue: $Issue"
            }
        }
        else {
            Write-Output "HEALTH CHECK: PASSED - No Windows Update issues detected"
        }
    }
    
    # Check 3: Time since last update
    $LastUpdate = Get-LastSuccessfulUpdate
    if ($LastUpdate) {
        $DaysSinceUpdate = ((Get-Date) - $LastUpdate).Days
        Write-Output "Days since last successful update: $DaysSinceUpdate"
        
        if ($DaysSinceUpdate -gt $MaxDaysSinceUpdate -and $BuildInfo.Build -lt $MinimumBuild) {
            $RequiresRemediation = $true
            $Reasons += "No successful updates in $DaysSinceUpdate days"
        }
    }
    
    # Final verdict
    if ($RequiresRemediation) {
        Write-Output ""
        Write-Output "=== REMEDIATION REQUIRED ==="
        foreach ($Reason in $Reasons) {
            Write-Output "- $Reason"
        }
        exit 1
    }
    else {
        Write-Output ""
        Write-Output "=== DEVICE IS COMPLIANT ==="
        Write-Output "No feature update required"
        exit 0
    }
}
catch {
    Write-Output "Detection script error: $_"
    # On error, assume compliant to avoid unnecessary remediation
    exit 0
}
#endregion
