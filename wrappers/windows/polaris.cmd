@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for polaris/polaris
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=polaris
set EXE_RELATIVE_PATH=polaris.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
