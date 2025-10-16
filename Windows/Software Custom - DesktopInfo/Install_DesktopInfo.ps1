<#
.SYNOPSIS
    Installs DesktopInfo system information overlay

.DESCRIPTION
    Installs DesktopInfo, a desktop wallpaper overlay that displays system
    information (computer name, IP, CPU, RAM, disk space, etc.).
    
    Copies executables and configuration files, creates a VBScript wrapper
    to hide PowerShell window, and sets up scheduled task for automatic
    startup at user logon.
    
.NOTES
    FileName:    Install_DesktopInfo.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 5.0+
    - Run as: System (Administrator privileges required)
    - Context: 64 Bit
    - Windows 10/11
    
    Exit Codes:
    - 0: Installation successful
    - 1: Installation failed
    
    External Dependencies:
    - DesktopInfo64.exe (must be in same directory)
    - hostname.ini (configuration file, must be in same directory)
    - DesktopInfo.ps1 (launcher script, must be in same directory)
    
    Configuration:
    - Installs to: C:\Program Files\DesktopInfo\
    - Creates scheduled task for user logon
    - Logs to: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\
    
    Impact:
    - Overlays system information on desktop wallpaper
    - Runs at every user logon
    - Minimal performance impact
    
    Change Log:
    v1.0 - Initial release
#>

$PackageName = "DesktopInfo"
$Description = "DesktopInfo"
$Prg_path = "$Env:Programfiles\DesktopInfo"

Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$PackageName-install.log" -Force

taskkill /IM DesktopInfo64.exe /F
# Initial Setup und Variabeln
$scriptSaveName = "DesktopInfo.ps1"
$scriptPath = "$Prg_path\$scriptSaveName"
New-item -itemtype directory -force -path "$Prg_path"
Copy-item -path ".\DesktopInfo64.exe" -destination "$Prg_path\DesktopInfo64.exe"
Copy-item -path ".\hostname.ini" -destination "$Prg_path\hostname.ini"
Copy-item -path ".\DesktopInfo.ps1" -destination $scriptPath

# Create dummy vbscript to hide PowerShell Window popping up at logon

$vbsDummyScript = "
Dim shell,fso,file

Set shell=CreateObject(`"WScript.Shell`")
Set fso=CreateObject(`"Scripting.FileSystemObject`")

strPath=WScript.Arguments.Item(0)

If fso.FileExists(strPath) Then
	set file=fso.GetFile(strPath)
	strCMD=`"powershell -nologo -executionpolicy ByPass -command `" & Chr(34) & `"&{`" &_
	file.ShortPath & `"}`" & Chr(34)
	shell.Run strCMD,0
End If
"

$scriptSaveName = "$PackageName-VBSHelper.vbs"

$dummyScriptPath = $(Join-Path -Path $Prg_path -ChildPath $scriptSaveName)

$vbsDummyScript | Out-File -FilePath $dummyScriptPath -Force

$wscriptPath = Join-Path $env:SystemRoot -ChildPath "System32\wscript.exe"

###########################################################################################
# Register a scheduled task to run for all users and execute the script on logon
###########################################################################################

$schtaskName = $PackageName
$schtaskDescription = $Description

$trigger = New-ScheduledTaskTrigger -AtLogOn

#Execute task in users context
$principal= New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545" -Id "Author"

#call the vbscript helper and pass the PosH script as argument
$action = New-ScheduledTaskAction -Execute $wscriptPath -Argument "`"$dummyScriptPath`" `"$scriptPath`""

$settings= New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

$null=Register-ScheduledTask -TaskName $schtaskName -Trigger $trigger -Action $action -Principal $principal -Settings $settings -Description $schtaskDescription -Force

Start-ScheduledTask -TaskName $schtaskName

Stop-Transcript