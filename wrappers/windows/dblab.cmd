@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for dblab/dblab
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=dblab
set EXE_RELATIVE_PATH=dblab.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
