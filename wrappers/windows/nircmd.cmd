@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for nircmd/nircmd
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=nircmd
set EXE_RELATIVE_PATH=nircmd.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
