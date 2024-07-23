<#
Version: 1.0
Author: 
- Brandon Miller-Mumford
Script: Clear-TeamsCache_Detection.ps1
Description: 
Version 1.0: Init
Run as: User
Context: 64 Bit
#> 

if(Test-Path -Path $env:APPDATA\"Microsoft\teams"){
    return 1
}else{
    return 0
}
