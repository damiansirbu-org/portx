@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for kalker/kalker
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=kalker
set EXE_RELATIVE_PATH=kalker.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
