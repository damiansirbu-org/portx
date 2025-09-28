@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for dust/dust
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=dust
set EXE_RELATIVE_PATH=dust.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
