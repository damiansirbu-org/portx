@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for kaf/kaf
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=kaf
set EXE_RELATIVE_PATH=bin/kaf.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
