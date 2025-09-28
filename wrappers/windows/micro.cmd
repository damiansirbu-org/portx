@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for micro/micro
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=micro
set EXE_RELATIVE_PATH=micro.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
