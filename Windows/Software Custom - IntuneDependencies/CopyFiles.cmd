@REM CopyFiles.cmd

@echo off

REM Check if directory exists, create if not
if not exist "C:\ProgramData\Intune" MD "C:\ProgramData\Intune"

REM Copy files to the directory
copy /Y ".\Wallpaper.png" "C:\ProgramData\Intune\" >nul
@REM copy /Y ".\TaskBar_Layout.xml" "C:\ProgramData\Intune\" >nul

REM Write to registry
powershell -Command "New-Item -Path HKLM:\Software\Intune -Force | Out-Null; Set-ItemProperty -Path HKLM:\Software\Intune -Name DependenciesCopied -Value $true -Force"

@echo [Files Copied and Registry Updated]
