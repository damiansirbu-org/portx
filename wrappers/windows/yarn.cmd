@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for yarn/yarn
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=yarn
set EXE_RELATIVE_PATH=yarn.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
