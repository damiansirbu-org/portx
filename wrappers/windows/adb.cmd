@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for scrcpy/adb
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=scrcpy
set EXE_RELATIVE_PATH=adb.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
