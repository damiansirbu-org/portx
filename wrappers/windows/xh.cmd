@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for xh/xh
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=xh
set EXE_RELATIVE_PATH=xh.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
