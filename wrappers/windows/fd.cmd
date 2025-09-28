@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for fd/fd
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=fd
set EXE_RELATIVE_PATH=fd.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
