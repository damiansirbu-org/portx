@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for kube-linter/kube-linter
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=kube-linter
set EXE_RELATIVE_PATH=kube-linter.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
