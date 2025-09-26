@echo off
REM PORTX 2.0 Universal Package Manager
REM Entry point for all PORTX operations across Windows, WSL, Cygwin, and containers

setlocal EnableDelayedExpansion

REM Detect and handle different command patterns
set "COMMAND=%~1"
set "SUBCOMMAND=%~2"

if "%COMMAND%"=="" (
    call :ShowHelp
    exit /b 0
)

if /i "%COMMAND%"=="import" (
    if "%SUBCOMMAND%"=="" (
        powershell.exe -ExecutionPolicy Bypass -File "%~dp0ps\portx-import.ps1" %2 %3 %4 %5 %6 %7 %8 %9
    ) else (
        powershell.exe -ExecutionPolicy Bypass -File "%~dp0ps\portx-import.ps1" -PackageName "%SUBCOMMAND%" %3 %4 %5 %6 %7 %8 %9
    )
    exit /b %ERRORLEVEL%
)

if /i "%COMMAND%"=="list" (
    powershell.exe -ExecutionPolicy Bypass -File "%~dp0ps\portx-list.ps1" %*
    exit /b %ERRORLEVEL%
)

if /i "%COMMAND%"=="help" (
    call :ShowHelp
    exit /b 0
)

REM Unknown command
echo Unknown command: %COMMAND%
echo.
call :ShowHelp
exit /b 1

:ShowHelp
echo PORTX 2.0 Universal Package Manager
echo.
echo Usage: portx ^<command^> [options]
echo.
echo Commands:
echo   import [package]     Import all packages or specific package
echo   list                 List all available packages and tools
echo   help                 Show this help message
echo.
echo Examples:
echo   portx import            Import all packages
echo   portx import git        Import only git package
echo   portx list              Show all packages
echo.
echo Cross-platform compatible: Windows, WSL, Cygwin, Linux containers
goto :eof