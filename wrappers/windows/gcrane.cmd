@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for crane/gcrane
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=crane
set EXE_RELATIVE_PATH=gcrane.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
