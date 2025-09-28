@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for httpx/httpx
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=httpx
set EXE_RELATIVE_PATH=httpx.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
