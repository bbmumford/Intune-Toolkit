@echo off
if "%~1"=="" (
    echo Printer name is missing.
    echo Usage: %~nx0 "Printer Name" "Data File"
    exit /b 1
)

if "%~2"=="" (
    echo Data file is missing.
    echo Usage: %~nx0 "Printer Name" "Data File"
    exit /b 1
)

set PRINTER_NAME=%~1
set DATA_FILE=%~2

rundll32 printui.dll,PrintUIEntry /Sr /n "%PRINTER_NAME%" /a "%DATA_FILE%"
