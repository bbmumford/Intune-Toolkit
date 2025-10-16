<#
.SYNOPSIS
    Clears Microsoft Teams cache to resolve performance issues

.DESCRIPTION
    Quits Microsoft Teams and clears all cache files from the user's AppData folder.
    Clears the following cache directories:
    - %APPDATA%\Microsoft\Teams\Cache
    - %APPDATA%\Microsoft\Teams\blob_storage
    - %APPDATA%\Microsoft\Teams\databases
    - %APPDATA%\Microsoft\Teams\GPUCache
    - %APPDATA%\Microsoft\Teams\IndexedDB
    - %APPDATA%\Microsoft\Teams\Local Storage
    - %APPDATA%\Microsoft\Teams\tmp
    
    Resolves issues such as:
    - Performance degradation
    - Login failures
    - Sync problems
    - Corrupt data
    
.NOTES
    FileName:    Clear-TeamsCache_Remediation.ps1
    Author:      Brandon Miller-Mumford
    Created:     
    Modified:    2025-10-16
    Version:     1.0
    
    Requirements:
    - PowerShell 2.0+
    - Run as: User (APPDATA context)
    - Context: 64 Bit
    - Microsoft Teams (Classic or New)
    - Intune Proactive Remediation Framework
    
    Exit Codes:
    - 0: Remediation successful (cache cleared)
    - 1: Remediation failed
    
    Impact:
    - Teams will close automatically
    - User will need to restart Teams
    - All cache data will be regenerated
    
    Change Log:
    v1.0 - Initial release
#>

Write-Host "Microsoft Teams will be quit now in order to clear the cache."
try{
    Get-Process -ProcessName Teams | Stop-Process -Force
    Start-Sleep -Seconds 5
    Write-Host "Microsoft Teams has been successfully quit."
}
catch{
    echo $_
}
# The cache is now being cleared.
try{
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\application cache\cache" | Remove-Item
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\blob_storage" | Remove-Item
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\databases" | Remove-Item
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\cache" | Remove-Item
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\gpucache" | Remove-Item
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Indexeddb" | Remove-Item
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Local Storage" | Remove-Item
Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\tmp" | Remove-Item
 
}
catch{
    echo $_
}
 
write-host "The Microsoft Teams cache has been successfully cleared."