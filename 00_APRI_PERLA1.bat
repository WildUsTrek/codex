@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title CODEX - Apri PERLA1

if not exist "PERLA1\AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat" goto missing

cd /d "%~dp0PERLA1"
call "AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat"
exit /b %errorlevel%

:missing
echo ERRORE: non trovo PERLA1\AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat
echo Questa cartella deve contenere la sottocartella PERLA1.
echo.
pause
exit /b 1
