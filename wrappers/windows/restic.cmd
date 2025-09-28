@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for restic/restic
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=restic
set EXE_RELATIVE_PATH=restic.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
