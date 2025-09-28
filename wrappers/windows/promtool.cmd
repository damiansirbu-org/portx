@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for monitoring/promtool
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=monitoring
set EXE_RELATIVE_PATH=promtool.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
