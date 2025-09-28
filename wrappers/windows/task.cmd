@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for task/task
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=task
set EXE_RELATIVE_PATH=task.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
