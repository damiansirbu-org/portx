@echo off
REM PORTX Professional Executable Builder
REM Purpose: Convert portx.bat to professional portx.exe with metadata and icon
REM Usage: build-portx-executable.bat

echo ========================================
echo PORTX Professional Executable Builder
echo ========================================
echo.

REM Check if required files exist
if not exist "portx.bat" (
    echo ERROR: portx.bat not found in root directory
    echo Please run this script from the PORTX root directory
    goto error
)

if not exist "build\bat2exe\Bat_To_Exe_Converter.exe" (
    echo ERROR: Bat_To_Exe_Converter.exe not found
    echo Expected location: build\bat2exe\Bat_To_Exe_Converter.exe
    goto error
)

if not exist "build\bat2exe\portx_icon.ico" (
    echo ERROR: portx_icon.ico not found
    echo Expected location: build\bat2exe\portx_icon.ico
    goto error
)

REM Read version from VERSION file
set /p VERSION=<VERSION
echo Building PORTX v%VERSION% executable...
echo.

REM Create the professional executable
echo [1/3] Converting BAT to EXE with professional metadata...
"build\bat2exe\Bat_To_Exe_Converter.exe" ^
  /bat "portx.bat" ^
  /exe "build\portx.exe" ^
  /icon "build\bat2exe\portx_icon.ico" ^
  /x64 ^
  /productname "PORTX Portable Development Environment" ^
  /description "Enterprise-grade portable POSIX toolkit with 538+ tools" ^
  /company "PORTX Development" ^
  /copyright "Copyright © 2025 PORTX Development" ^
  /fileversion "%VERSION%.0" ^
  /productversion "%VERSION%" ^
  /comments "Corporate-friendly portable development environment built on Git for Windows" ^
  /overwrite

if not exist "build\portx.exe" (
    echo ERROR: Failed to create executable
    goto error
)

echo ✓ Executable created successfully

REM Move to root directory (like a boss!)
echo [2/3] Installing executable to root directory...
copy "build\portx.exe" "portx.exe" >nul
if exist "portx.exe" (
    echo ✓ Installed to root: portx.exe
) else (
    echo ERROR: Failed to copy to root directory
    goto error
)

REM Show results
echo [3/3] Build complete!
echo.
echo ========================================
echo SUCCESS: Professional PORTX executable created
echo ========================================
echo.
echo Product: PORTX Portable Development Environment
echo Version: %VERSION%
echo Size: 
dir portx.exe | findstr portx.exe
echo.
echo Files created:
echo   • build\portx.exe (build artifact)
echo   • portx.exe       (root installation - like a boss!)
echo.
echo Corporate features:
echo   ✓ Custom PORTX icon
echo   ✓ Professional metadata
echo   ✓ Version information
echo   ✓ 64-bit executable
echo   ✓ Corporate branding
echo.
echo Usage: .\portx.exe
echo.
goto end

:error
echo.
echo ========================================
echo BUILD FAILED
echo ========================================
echo.
echo Please check the error messages above and ensure:
echo   1. You're running from PORTX root directory
echo   2. All required files are present
echo   3. Bat_To_Exe_Converter.exe has proper permissions
echo.

:end
pause