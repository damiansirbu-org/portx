@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for sonar-scanner/sonar-scanner
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=sonar-scanner
set EXE_RELATIVE_PATH=sonar-scanner.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
