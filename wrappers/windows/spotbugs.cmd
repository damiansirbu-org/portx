@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for spotbugs/spotbugs
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=spotbugs
set EXE_RELATIVE_PATH=spotbugs.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
