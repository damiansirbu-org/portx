@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for tinycc/tcc
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=tinycc
set EXE_RELATIVE_PATH=tcc.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
