@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for sysinternals/autorunsc64
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=sysinternals
set EXE_RELATIVE_PATH=autorunsc64.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
