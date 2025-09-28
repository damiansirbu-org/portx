@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for python-runtime/python
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=python-runtime
set EXE_RELATIVE_PATH=python.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
