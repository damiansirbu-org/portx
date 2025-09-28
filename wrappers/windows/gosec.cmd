@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for gosec/gosec
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=gosec
set EXE_RELATIVE_PATH=gosec.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
