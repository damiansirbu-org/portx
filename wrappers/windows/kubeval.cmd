@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for kubeval/kubeval
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=kubeval
set EXE_RELATIVE_PATH=kubeval.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
