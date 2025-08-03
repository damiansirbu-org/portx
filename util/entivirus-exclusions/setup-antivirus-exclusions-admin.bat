@echo off
:: PORTX Antivirus Exclusion Setup - Auto-Elevate to Administrator
:: Automatically runs the PowerShell antivirus exclusion script with admin privileges

setlocal EnableDelayedExpansion

echo.
echo ===============================================
echo  PORTX Antivirus Exclusion Setup (Admin)
echo ===============================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% equ 0 goto :run_script

:: Not running as admin - request elevation
echo [INFO] Requesting administrator privileges...
echo [INFO] Click "Yes" on the UAC prompt to continue...
echo.

:: Re-run this script with admin privileges
powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
exit /b 0

:run_script
echo [INFO] Running with administrator privileges...
echo.

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Add-PortxAntivirusExclusions.ps1"

:: Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo [ERROR] PowerShell script not found: %PS_SCRIPT%
    echo.
    echo Please ensure the following file exists:
    echo %PS_SCRIPT%
    echo.
    pause
    exit /b 1
)

echo [INFO] Starting PORTX antivirus exclusion configuration...
echo.

:: Run PowerShell script with Force parameter for automated execution
powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Force

:: Check PowerShell exit code
if %errorLevel% equ 0 (
    echo.
    echo ===============================================
    echo  PORTX Antivirus Exclusions Configured!
    echo ===============================================
    echo.
    echo Your PORTX environment is now optimized for:
    echo   • 2-5x faster Git operations
    echo   • Reduced shell startup time
    echo   • Instant tool execution
    echo   • Faster build processes
    echo.
    echo Performance optimization complete!
    echo.
) else (
    echo.
    echo ===============================================
    echo  Configuration Issues Detected
    echo ===============================================
    echo.
    echo Some exclusions may require manual configuration.
    echo Check the output above for specific instructions.
    echo.
)

echo Press any key to exit...
pause >nul