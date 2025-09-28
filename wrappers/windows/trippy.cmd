@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for trippy/trippy
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=trippy
set EXE_RELATIVE_PATH=trip.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
