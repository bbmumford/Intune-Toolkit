<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Clear-TeamsCache_Remediation.ps1
Description: 
Version 1.0: Init
Run as: User
Context: 64 Bit
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