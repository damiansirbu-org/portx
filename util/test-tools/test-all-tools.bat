@echo off
:: PORTX Tool Testing Script - Comprehensive Executable Validation
:: Tests all executables across usr/bin, bin-ext, bin-tools and produces detailed report

setlocal EnableDelayedExpansion

echo.
echo ===============================================
echo  PORTX Comprehensive Tool Testing
echo ===============================================
echo.

:: Set up environment
set "PORTX_ROOT=%~dp0.."
set "TEST_LOG=%PORTX_ROOT%\tool-test-report.txt"
set "TEST_SUMMARY=%PORTX_ROOT%\tool-test-summary.txt"

:: Initialize counters
set /a TOTAL_TOOLS=0
set /a WORKING_TOOLS=0
set /a BROKEN_TOOLS=0
set /a MISSING_TOOLS=0

:: Create report header
echo PORTX Tool Testing Report - %DATE% %TIME% > "%TEST_LOG%"
echo ============================================== >> "%TEST_LOG%"
echo. >> "%TEST_LOG%"

echo [INFO] Starting comprehensive tool testing...
echo [INFO] Report will be saved to: %TEST_LOG%
echo [INFO] Summary will be saved to: %TEST_SUMMARY%
echo.

:: Test usr/bin executables (MSYS2 tools)
echo [TESTING] MSYS2 Tools (usr/bin)...
echo === MSYS2 TOOLS (usr/bin) === >> "%TEST_LOG%"
call :test_directory "%PORTX_ROOT%\usr\bin" "MSYS2"

:: Test bin-ext executables (PORTX enhanced tools)
echo [TESTING] PORTX Enhanced Tools (bin-ext)...
echo. >> "%TEST_LOG%"
echo === PORTX ENHANCED TOOLS (bin-ext) === >> "%TEST_LOG%"
call :test_directory "%PORTX_ROOT%\bin-ext" "PORTX-Enhanced"

:: Test bin-tools executables (Professional tools)
echo [TESTING] Professional Tools (bin-tools)...
echo. >> "%TEST_LOG%"
echo === PROFESSIONAL TOOLS (bin-tools) === >> "%TEST_LOG%"
call :test_tools_directory "%PORTX_ROOT%\bin-tools"

:: Test mingw64/bin executables (Git for Windows tools)
echo [TESTING] Git for Windows Tools (mingw64/bin)...
echo. >> "%TEST_LOG%"
echo === GIT FOR WINDOWS TOOLS (mingw64/bin) === >> "%TEST_LOG%"
call :test_directory "%PORTX_ROOT%\mingw64\bin" "Git4Win"

:: Generate summary
call :generate_summary

echo.
echo ===============================================
echo  Testing Complete!
echo ===============================================
echo.
echo Summary:
echo   Total Tools Tested: !TOTAL_TOOLS!
echo   Working Tools: !WORKING_TOOLS!
echo   Broken Tools: !BROKEN_TOOLS!
echo   Missing Tools: !MISSING_TOOLS!
echo.
echo Detailed report: %TEST_LOG%
echo Summary report: %TEST_SUMMARY%
echo.
echo Press any key to view summary...
pause >nul

:: Show summary
type "%TEST_SUMMARY%"
echo.
echo Press any key to exit...
pause >nul
exit /b 0

:: Function to test executables in a directory
:test_directory
set "TEST_DIR=%~1"
set "CATEGORY=%~2"

if not exist "%TEST_DIR%" (
    echo [WARNING] Directory not found: %TEST_DIR%
    echo WARNING: Directory not found: %TEST_DIR% >> "%TEST_LOG%"
    exit /b 0
)

for %%f in ("%TEST_DIR%\*.exe") do (
    set /a TOTAL_TOOLS+=1
    set "TOOL_NAME=%%~nf"
    set "TOOL_PATH=%%f"
    
    echo Testing: !TOOL_NAME!
    
    :: Test tool with --version, -V, --help, -h flags
    call :test_executable "!TOOL_PATH!" "!TOOL_NAME!" "%CATEGORY%"
)

exit /b 0

:: Function to test tools directory (recursive for packages)
:test_tools_directory
set "TOOLS_DIR=%~1"

if not exist "%TOOLS_DIR%" (
    echo [WARNING] Tools directory not found: %TOOLS_DIR%
    echo WARNING: Tools directory not found: %TOOLS_DIR% >> "%TEST_LOG%"
    exit /b 0
)

:: Test direct executables in bin-tools
for %%f in ("%TOOLS_DIR%\*.exe") do (
    set /a TOTAL_TOOLS+=1
    set "TOOL_NAME=%%~nf"
    set "TOOL_PATH=%%f"
    
    echo Testing: !TOOL_NAME!
    call :test_executable "!TOOL_PATH!" "!TOOL_NAME!" "Tools-Direct"
)

:: Test executables in package subdirectories
for /d %%d in ("%TOOLS_DIR%\*") do (
    for %%f in ("%%d\*.exe") do (
        set /a TOTAL_TOOLS+=1
        set "TOOL_NAME=%%~nf"
        set "TOOL_PATH=%%f"
        set "PACKAGE_NAME=%%~nd"
        
        echo Testing: !PACKAGE_NAME!/!TOOL_NAME!
        call :test_executable "!TOOL_PATH!" "!TOOL_NAME!" "Tools-!PACKAGE_NAME!"
    )
)

exit /b 0

:: Function to test individual executable
:test_executable
set "EXEC_PATH=%~1"
set "EXEC_NAME=%~2"
set "EXEC_CATEGORY=%~3"

set "TEST_RESULT=UNKNOWN"
set "ERROR_MSG="

:: Test if file exists and is executable
if not exist "%EXEC_PATH%" (
    set "TEST_RESULT=MISSING"
    set "ERROR_MSG=File not found"
    set /a MISSING_TOOLS+=1
    goto :log_result
)

:: Try different help/version flags
set "TEST_RESULT=BROKEN"

:: Test --version
"%EXEC_PATH%" --version >nul 2>&1
if !errorlevel! equ 0 (
    set "TEST_RESULT=WORKING"
    set /a WORKING_TOOLS+=1
    goto :log_result
)

:: Test -V
"%EXEC_PATH%" -V >nul 2>&1
if !errorlevel! equ 0 (
    set "TEST_RESULT=WORKING"
    set /a WORKING_TOOLS+=1
    goto :log_result
)

:: Test --help
"%EXEC_PATH%" --help >nul 2>&1
if !errorlevel! equ 0 (
    set "TEST_RESULT=WORKING"
    set /a WORKING_TOOLS+=1
    goto :log_result
)

:: Test -h
"%EXEC_PATH%" -h >nul 2>&1
if !errorlevel! equ 0 (
    set "TEST_RESULT=WORKING"
    set /a WORKING_TOOLS+=1
    goto :log_result
)

:: Test no arguments (some tools show help by default)
"%EXEC_PATH%" >nul 2>&1
if !errorlevel! equ 0 (
    set "TEST_RESULT=WORKING"
    set /a WORKING_TOOLS+=1
    goto :log_result
)

:: If we get here, tool is probably broken
set /a BROKEN_TOOLS+=1
set "ERROR_MSG=No response to help/version flags"

:log_result
:: Log to detailed report
echo [%TEST_RESULT%] %EXEC_CATEGORY%/%EXEC_NAME% - %ERROR_MSG% >> "%TEST_LOG%"

:: Show progress
if "%TEST_RESULT%"=="WORKING" (
    echo   ✓ %EXEC_NAME%
) else if "%TEST_RESULT%"=="BROKEN" (
    echo   ✗ %EXEC_NAME% - %ERROR_MSG%
) else (
    echo   ? %EXEC_NAME% - %ERROR_MSG%
)

exit /b 0

:: Function to generate summary report
:generate_summary
echo PORTX Tool Testing Summary - %DATE% %TIME% > "%TEST_SUMMARY%"
echo ============================================== >> "%TEST_SUMMARY%"
echo. >> "%TEST_SUMMARY%"
echo Total Tools Tested: !TOTAL_TOOLS! >> "%TEST_SUMMARY%"
echo Working Tools: !WORKING_TOOLS! >> "%TEST_SUMMARY%"
echo Broken Tools: !BROKEN_TOOLS! >> "%TEST_SUMMARY%"
echo Missing Tools: !MISSING_TOOLS! >> "%TEST_SUMMARY%"
echo. >> "%TEST_SUMMARY%"

set /a SUCCESS_RATE=(!WORKING_TOOLS! * 100) / !TOTAL_TOOLS!
echo Success Rate: !SUCCESS_RATE!%% >> "%TEST_SUMMARY%"
echo. >> "%TEST_SUMMARY%"

echo === BROKEN TOOLS === >> "%TEST_SUMMARY%"
findstr "^\[BROKEN\]" "%TEST_LOG%" >> "%TEST_SUMMARY%"
echo. >> "%TEST_SUMMARY%"

echo === MISSING TOOLS === >> "%TEST_SUMMARY%"
findstr "^\[MISSING\]" "%TEST_LOG%" >> "%TEST_SUMMARY%"
echo. >> "%TEST_SUMMARY%"

echo === ANALYSIS === >> "%TEST_SUMMARY%"
if !BROKEN_TOOLS! gtr 0 (
    echo - !BROKEN_TOOLS! tools need investigation or replacement >> "%TEST_SUMMARY%"
)
if !MISSING_TOOLS! gtr 0 (
    echo - !MISSING_TOOLS! tools are missing files >> "%TEST_SUMMARY%"
)
if !SUCCESS_RATE! lss 90 (
    echo - Success rate below 90%% - significant issues detected >> "%TEST_SUMMARY%"
) else (
    echo - Good success rate - minor issues only >> "%TEST_SUMMARY%"
)

exit /b 0