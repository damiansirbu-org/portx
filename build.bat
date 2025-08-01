@echo off
setlocal enabledelayedexpansion

:: Read version from VERSION file
set /p VERSION=<VERSION
set ARCHIVE_NAME=portx-%VERSION%.zip

echo Building PORTX %VERSION%...

:: Clean previous build
if exist "%ARCHIVE_NAME%" del "%ARCHIVE_NAME%"

:: Create zip using 7za (from PORTX tools)
7za a -tzip "%ARCHIVE_NAME%" . -x!.git -x!.claude -x!*.zip -x!*.bat -x!Makefile -x!build.ps1

if exist "%ARCHIVE_NAME%" (
    echo Build complete: %ARCHIVE_NAME%
    for %%A in ("%ARCHIVE_NAME%") do echo Archive size: %%~zA bytes
) else (
    echo Build failed!
    exit /b 1
)

pause