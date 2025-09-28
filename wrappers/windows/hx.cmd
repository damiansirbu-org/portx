@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for helix/hx
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=helix
set EXE_RELATIVE_PATH=hx.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
