@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for capture2text/capture2text-cli
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=capture2text
set EXE_RELATIVE_PATH=Capture2Text_CLI.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
