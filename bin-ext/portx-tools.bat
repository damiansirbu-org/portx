@echo off
REM PORTX Tools Manager - Multi-mode tool interface
REM Usage: 
REM   portx-tools         - Show tool count
REM   portx-tools find    - Open interactive tool finder
REM   portx-tools help    - Show help

setlocal enabledelayedexpansion

set "PORTX_ROOT=%PORTX_ROOT%"
if "%PORTX_ROOT%"=="" set "PORTX_ROOT=C:/App/PORTX"
set "TOOLS_FILE=%PORTX_ROOT%/doc-portx/tools-researched.txt"

REM Check if tools file exists
if not exist "%TOOLS_FILE%" (
    echo Error: Tools file not found: %TOOLS_FILE%
    exit /b 1
)

REM Handle different modes
if "%1"=="" goto show_count
if /i "%1"=="find" goto launch_finder
if /i "%1"=="help" goto show_help
if /i "%1"=="-h" goto show_help
if /i "%1"=="--help" goto show_help

REM Default: show count
:show_count
REM Count non-empty, non-comment lines
for /f %%i in ('type "%TOOLS_FILE%" ^| findstr /v "^#" ^| findstr /v "^$" ^| find /c /v ""') do (
    echo %%i
)
exit /b 0

:launch_finder
REM Launch the interactive tool finder using Git Bash
if exist "%PORTX_ROOT%/bin-ext/portx-find-tools" (
    bash "%PORTX_ROOT%/bin-ext/portx-find-tools"
) else (
    echo Error: Tool finder not found at %PORTX_ROOT%/bin-ext/portx-find-tools
    exit /b 1
)
exit /b 0

:show_help
echo PORTX Tools Manager
echo.
echo USAGE:
echo   portx-tools           Show total number of available tools
echo   portx-tools find      Launch interactive tool finder with search and preview
echo   portx-tools help      Show this help message
echo.
echo EXAMPLES:
echo   portx-tools           # Output: 538
echo   portx-tools find      # Opens fzf-based tool browser
echo.
echo The tool database contains professionally curated information for all PORTX tools
echo with detailed descriptions, usage examples, and categorization.
exit /b 0