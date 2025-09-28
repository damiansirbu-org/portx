@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for vegeta/vegeta
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=vegeta
set EXE_RELATIVE_PATH=vegeta.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
