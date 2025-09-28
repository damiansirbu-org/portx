@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for xsv/xsv
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=xsv
set EXE_RELATIVE_PATH=xsv.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
