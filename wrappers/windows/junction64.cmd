@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for sysinternals/junction64
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=sysinternals
set EXE_RELATIVE_PATH=junction64.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
