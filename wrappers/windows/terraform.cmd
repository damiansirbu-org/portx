@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for terraform/terraform
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=terraform
set EXE_RELATIVE_PATH=terraform.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
