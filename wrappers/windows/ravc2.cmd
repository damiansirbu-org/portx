@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for radare2/ravc2
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=radare2
set EXE_RELATIVE_PATH=bin/ravc2.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
