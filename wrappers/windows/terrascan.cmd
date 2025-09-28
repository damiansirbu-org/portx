@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for terrascan/terrascan
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=terrascan
set EXE_RELATIVE_PATH=terrascan.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
