@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for go/gofmt
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=go
set EXE_RELATIVE_PATH=bin/gofmt.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
