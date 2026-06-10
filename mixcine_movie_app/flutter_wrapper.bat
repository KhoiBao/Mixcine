@echo off
setlocal enabledelayedexpansion
set FLUTTER_ROOT=E:\flutter + dart\flutter
set PATH=!FLUTTER_ROOT!\bin;%PATH%
"%FLUTTER_ROOT%\bin\flutter.bat" %*
