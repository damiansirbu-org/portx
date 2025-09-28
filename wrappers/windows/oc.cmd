@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for openshift/oc
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=openshift
set EXE_RELATIVE_PATH=oc.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
