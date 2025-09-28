@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for jo/jo
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=jo
set EXE_RELATIVE_PATH=jo.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
