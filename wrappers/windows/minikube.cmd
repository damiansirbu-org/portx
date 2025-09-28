@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for minikube/minikube
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=minikube
set EXE_RELATIVE_PATH=minikube.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
