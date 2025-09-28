@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for aria2/aria2c
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=aria2
set EXE_RELATIVE_PATH=aria2c.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
