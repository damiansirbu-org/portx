@echo off
rem PORTX Universal Wrapper for capture2text/capture2text-cli
rem Calls universal portx-wrap.exe with intelligent path conversion

set PORTX_ROOT=C:\App\PORTX

"%PORTX_ROOT%\go\target\portx-wrap.exe" "capture2text-cli" %*
