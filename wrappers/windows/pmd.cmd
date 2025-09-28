@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for pmd/pmd
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=pmd
set EXE_RELATIVE_PATH=pmd.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
