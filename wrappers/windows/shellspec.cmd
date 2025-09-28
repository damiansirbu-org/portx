@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for shellspec/shellspec
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=shellspec
set EXE_RELATIVE_PATH=shellspec.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
