@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for sd/sd
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=sd
set EXE_RELATIVE_PATH=sd.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
