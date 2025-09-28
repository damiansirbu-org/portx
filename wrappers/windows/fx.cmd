@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for fx/fx
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=fx
set EXE_RELATIVE_PATH=fx.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
