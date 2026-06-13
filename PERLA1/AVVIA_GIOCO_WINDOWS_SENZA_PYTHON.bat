@echo off
setlocal
title PERLA1 V274 - Geometric Eave Edge Server
cd /d "%~dp0"

echo ============================================================
echo  PERLA1 V274 - GEOMETRIC EAVE EDGE SAFE - AVVIO
echo ============================================================
echo.
echo Uso PowerShell integrato in Windows.
echo Se trova un vecchio server PERLA1 sulla porta 8000, prova a chiuderlo automaticamente.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0AVVIA_GIOCO_SERVER_POWERSHELL.ps1" -Port 8000 -KillExisting

echo.
echo Il server si e' fermato.
echo Se vedi errori reali, mandami il file AVVIO_GIOCO_POWERSHELL_LOG.txt
echo.
pause
endlocal
