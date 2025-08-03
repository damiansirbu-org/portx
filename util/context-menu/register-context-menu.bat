@echo off
:: PORTX Context Menu Registration - Simplified Working Version
:: Adds "Open PORTX here" to Windows Explorer right-click context menu

setlocal EnableDelayedExpansion

echo.
echo ===============================================
echo  PORTX Context Menu Registration
echo ===============================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Administrator privileges required!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo to register the context menu.
    echo.
    pause
    exit /b 1
)

:: Auto-detect PORTX installation
set "PORTX_PATH="
for %%p in ("C:\App\PORTX" "C:\Tools\PORTX" "C:\PORTX" "%USERPROFILE%\PORTX") do (
    if exist "%%~p\portx-wrapper.cmd" (
        set "PORTX_PATH=%%~p"
        goto :found_portx
    )
)

:found_portx
if "%PORTX_PATH%"=="" (
    echo [ERROR] PORTX installation not found!
    echo.
    echo Please ensure PORTX is installed with portx-wrapper.cmd in one of these locations:
    echo   - C:\App\PORTX
    echo   - C:\Tools\PORTX
    echo   - C:\PORTX
    echo   - %USERPROFILE%\PORTX
    echo.
    pause
    exit /b 1
)

echo [INFO] Found PORTX at: %PORTX_PATH%

:: Set executables and icon paths
set "PORTX_WRAPPER=%PORTX_PATH%\portx-wrapper.cmd"
set "PORTX_ICON=%PORTX_PATH%\portx.ico"

echo [INFO] Using wrapper: %PORTX_WRAPPER%
echo [INFO] Using icon: %PORTX_ICON%
echo.

:: Menu options
echo Choose an option:
echo.
echo 1. Register "Open PORTX here" context menu
echo 2. Unregister context menu
echo 3. Exit
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto :register
if "%choice%"=="2" goto :unregister
if "%choice%"=="3" goto :exit
goto :invalid_choice

:register
echo.
echo [INFO] Registering PORTX context menu...

:: Register for folder background (when right-clicking in empty space)
reg add "HKCR\Directory\Background\shell\OpenPORTX" /ve /d "Open PORTX here" /f
reg add "HKCR\Directory\Background\shell\OpenPORTX" /v "Icon" /d "\"%PORTX_ICON%\"" /f
reg add "HKCR\Directory\Background\shell\OpenPORTX\command" /ve /d "\"%PORTX_WRAPPER%\"" /f
reg add "HKCR\Directory\Background\shell\OpenPORTX" /v "WorkingDirectory" /d "%%V" /f

:: Register for folder (when right-clicking on a folder)
reg add "HKCR\Directory\shell\OpenPORTX" /ve /d "Open PORTX here" /f
reg add "HKCR\Directory\shell\OpenPORTX" /v "Icon" /d "\"%PORTX_ICON%\"" /f
reg add "HKCR\Directory\shell\OpenPORTX\command" /ve /d "\"%PORTX_WRAPPER%\"" /f
reg add "HKCR\Directory\shell\OpenPORTX" /v "WorkingDirectory" /d "%%1" /f

:: Register for drives (when right-clicking on drive letters)
reg add "HKCR\Drive\shell\OpenPORTX" /ve /d "Open PORTX here" /f
reg add "HKCR\Drive\shell\OpenPORTX" /v "Icon" /d "\"%PORTX_ICON%\"" /f
reg add "HKCR\Drive\shell\OpenPORTX\command" /ve /d "\"%PORTX_WRAPPER%\"" /f
reg add "HKCR\Drive\shell\OpenPORTX" /v "WorkingDirectory" /d "%%1" /f

if %errorLevel% equ 0 (
    echo [SUCCESS] PORTX context menu registered successfully!
    echo.
    echo You can now right-click in any folder and select "Open PORTX here"
    echo to launch PORTX in that directory.
    echo.
    echo Features:
    echo   - Right-click in folder background
    echo   - Right-click on any folder
    echo   - Right-click on drive letters
    echo   - Uses PORTX icon for visual recognition
    echo.
) else (
    echo [ERROR] Failed to register context menu.
)
goto :end

:unregister
echo.
echo [INFO] Unregistering PORTX context menu...

:: Remove registry entries
reg delete "HKCR\Directory\Background\shell\OpenPORTX" /f >nul 2>&1
reg delete "HKCR\Directory\shell\OpenPORTX" /f >nul 2>&1
reg delete "HKCR\Drive\shell\OpenPORTX" /f >nul 2>&1

echo [SUCCESS] PORTX context menu unregistered successfully!
echo.
echo The "Open PORTX here" option has been removed from the context menu.
goto :end

:invalid_choice
echo.
echo [ERROR] Invalid choice. Please enter 1, 2, or 3.
echo.
goto :register

:end
echo.
echo ===============================================
echo  Operation completed
echo ===============================================
echo.
echo NOTE: If the icon doesn't appear immediately, try:
echo   1. Restart Windows Explorer (Ctrl+Shift+Esc → Restart explorer.exe)
echo   2. Refresh the desktop (F5)
echo   3. Clear icon cache: ie4uinit.exe -show
echo.

:exit
echo Press any key to exit...
pause >nul