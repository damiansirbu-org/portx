@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for everything/es
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=everything
set EXE_RELATIVE_PATH=es.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
