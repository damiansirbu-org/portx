@echo off
rem PORTX Universal Wrapper for graphwiz/neato
rem Calls universal portx-wrap.exe with intelligent path conversion

set PORTX_ROOT=C:\App\PORTX

"%PORTX_ROOT%\go\target\portx-wrap.exe" "neato" %*
