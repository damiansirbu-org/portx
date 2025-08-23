@echo off
:: PORTX Antivirus Exclusion Setup Launcher
:: Automatically configures antivirus exclusions for optimal PORTX performance

setlocal EnableDelayedExpansion

echo.
echo ===============================================
echo  PORTX Antivirus Exclusion Setup
echo ===============================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Administrator privileges required!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo or run from an elevated command prompt.
    echo.
    pause
    exit /b 1
)

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Add-PortxAntivirusExclusions.ps1"

:: Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo [ERROR] PowerShell script not found: %PS_SCRIPT%
    echo.
    pause
    exit /b 1
)

:: Check PowerShell execution policy
echo [INFO] Checking PowerShell execution policy...
for /f "tokens=*" %%i in ('powershell -Command "Get-ExecutionPolicy"') do set "EXEC_POLICY=%%i"

if /i "!EXEC_POLICY!"=="Restricted" (
    echo [WARNING] PowerShell execution policy is Restricted
    echo [INFO] Temporarily allowing script execution...
    
    :: Run with bypass for this session only
    echo [INFO] Running PORTX antivirus exclusion setup...
    powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
) else (
    echo [INFO] PowerShell execution policy: !EXEC_POLICY!
    echo [INFO] Running PORTX antivirus exclusion setup...
    powershell -File "%PS_SCRIPT%" %*
)

:: Check PowerShell exit code
if %errorLevel% equ 0 (
    echo.
    echo ===============================================
    echo  Setup completed successfully!
    echo ===============================================
    echo.
    echo Your PORTX environment should now run faster
    echo with reduced antivirus scanning interference.
    echo.
) else (
    echo.
    echo ===============================================
    echo  Setup encountered issues
    echo ===============================================
    echo.
    echo Check the output above for any error messages
    echo or manual configuration requirements.
    echo.
)

echo Press any key to exit...
pause >nul