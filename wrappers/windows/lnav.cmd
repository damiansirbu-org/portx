@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for lnav/lnav
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=lnav
set EXE_RELATIVE_PATH=bin/lnav.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
