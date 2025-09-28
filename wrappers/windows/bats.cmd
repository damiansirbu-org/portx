@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for bats/bats
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=bats
set EXE_RELATIVE_PATH=bats.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
