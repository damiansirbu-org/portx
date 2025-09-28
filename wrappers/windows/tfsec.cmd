@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for tfsec/tfsec
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=tfsec
set EXE_RELATIVE_PATH=tfsec.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
