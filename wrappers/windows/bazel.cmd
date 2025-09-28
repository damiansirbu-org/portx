@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for bazel/bazel
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=bazel
set EXE_RELATIVE_PATH=bazel.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
