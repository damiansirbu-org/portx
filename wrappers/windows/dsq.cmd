@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for dsq/dsq
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=dsq
set EXE_RELATIVE_PATH=dsq.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
