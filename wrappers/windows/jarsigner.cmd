@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for java/jarsigner
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=java
set EXE_RELATIVE_PATH=bin/jarsigner.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
