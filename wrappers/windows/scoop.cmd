@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for scoop/scoop
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=scoop
set EXE_RELATIVE_PATH=scoop.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
