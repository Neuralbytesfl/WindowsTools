@echo off
@REM Needed in order to compile-self hosted
powershell -ExecutionPolicy Bypass -File "%~dp0test.ps1" 
pause
