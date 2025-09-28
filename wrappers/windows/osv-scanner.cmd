@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for osv-scanner/osv-scanner
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=osv-scanner
set EXE_RELATIVE_PATH=osv-scanner.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
