@REM CopyFiles.cmd

@echo off

REM Check if directory exists, create if not
if not exist "C:\IntuneDependencies" MD "C:\IntuneDependencies"

REM Copy files to the directory
copy /Y ".\Wallpaper.png" C:\IntuneDependencies\ >nul
@REM copy /Y ".\TaskBar_Layout.xml" C:\IntuneDependencies\ >nul

REM Write to registry
powershell -Command "New-Item -Path HKLM:\Software\IntuneDependencies -Force | Out-Null; Set-ItemProperty -Path HKLM:\Software\IntuneDependencies -Name DependenciesCopied -Value $true -Force"

@echo [Files Copied and Registry Updated]
