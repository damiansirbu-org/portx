@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for yara/yara32
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=yara
set EXE_RELATIVE_PATH=yara32.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
