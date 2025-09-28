@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for dog/dog
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=dog
set EXE_RELATIVE_PATH=bin/dog.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
