@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for sysinternals/psfile64
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=sysinternals
set EXE_RELATIVE_PATH=psfile64.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
