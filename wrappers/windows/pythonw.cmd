@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for python-runtime/pythonw
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=python-runtime
set EXE_RELATIVE_PATH=pythonw.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
