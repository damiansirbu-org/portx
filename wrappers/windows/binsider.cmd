@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for binsider/binsider
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=binsider
set EXE_RELATIVE_PATH=binsider.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
