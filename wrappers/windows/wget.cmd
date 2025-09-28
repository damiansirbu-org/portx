@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for wget/wget
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=wget
set EXE_RELATIVE_PATH=wget.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
