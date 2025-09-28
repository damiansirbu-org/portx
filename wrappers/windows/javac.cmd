@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for java/javac
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=java
set EXE_RELATIVE_PATH=bin/javac.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
