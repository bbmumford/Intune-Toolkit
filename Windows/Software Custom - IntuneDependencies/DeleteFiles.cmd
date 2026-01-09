@REM DeleteFiles.cmd

@echo off

REM Remove the Dependencies folder if it exists
if exist "C:\ProgramData\Intune" (
    rmdir /S /Q "C:\ProgramData\Intune"
)

REM Remove the specific registry key
powershell -Command "Remove-ItemProperty -Path HKLM:\Software\Intune -Name DependenciesCopied -Force"

@echo [Dependencies Folder and Registry Key Removed]
