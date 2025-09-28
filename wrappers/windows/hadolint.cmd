@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for hadolint/hadolint
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=hadolint
set EXE_RELATIVE_PATH=hadolint.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
