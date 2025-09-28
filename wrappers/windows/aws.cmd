@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for aws/aws
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=aws
set EXE_RELATIVE_PATH=aws.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
