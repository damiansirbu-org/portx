@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for wrk/wrk
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=wrk
set EXE_RELATIVE_PATH=go-wrk.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
