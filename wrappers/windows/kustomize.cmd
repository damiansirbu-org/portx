@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for k8/kustomize
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=k8
set EXE_RELATIVE_PATH=kustomize.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
