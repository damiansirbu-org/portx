@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for helm/helm
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=helm
set EXE_RELATIVE_PATH=helm.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
