@REM DeleteFiles.cmd

@echo off

REM Remove the Dependencies folder if it exists
if exist "C:\IntuneDependencies" (
    rmdir /S /Q "C:\IntuneDependencies"
)

REM Remove the specific registry key
powershell -Command "Remove-ItemProperty -Path HKLM:\Software\IntuneDependencies -Name DependenciesCopied -Force"

@echo [Dependencies Folder and Registry Key Removed]
