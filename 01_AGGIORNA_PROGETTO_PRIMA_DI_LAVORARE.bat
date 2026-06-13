@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title CODEX - 01 Aggiorna prima di lavorare

echo ============================================================
echo  CODEX / PERLA1 - AGGIORNA PRIMA DI LAVORARE
echo ============================================================
echo.

call :find_git
if not defined GIT_EXE goto no_git

if not exist ".git" goto no_repo

for /f "delims=" %%B in ('"%GIT_EXE%" rev-parse --abbrev-ref HEAD 2^>nul') do set BRANCH=%%B
if not defined BRANCH set BRANCH=main

for /f "delims=" %%S in ('"%GIT_EXE%" status --porcelain') do set HAS_CHANGES=1
if defined HAS_CHANGES (
  echo ATTENZIONE: ci sono modifiche locali non ancora salvate.
  echo.
  "%GIT_EXE%" status --short
  echo.
  echo Per sicurezza NON aggiorno da GitHub.
  echo Prima usa 02_SALVA_PROGETTO_SU_GITHUB.bat oppure apri GitHub Desktop.
  echo.
  pause
  exit /b 1
)

echo Scarico aggiornamenti da GitHub...
"%GIT_EXE%" fetch origin
if errorlevel 1 goto git_error

echo Applico aggiornamenti su %BRANCH%...
"%GIT_EXE%" pull --ff-only origin %BRANCH%
if errorlevel 1 goto pull_error

echo.
echo OK: progetto aggiornato. Puoi lavorare.
echo.
pause
exit /b 0

:find_git
where git >nul 2>nul
if not errorlevel 1 (
  for /f "delims=" %%G in ('where git') do if not defined GIT_EXE set "GIT_EXE=%%G"
)
if defined GIT_EXE exit /b 0
for /f "delims=" %%G in ('dir /b /s "%LOCALAPPDATA%\GitHubDesktop\app-*\resources\app\git\cmd\git.exe" 2^>nul') do if not defined GIT_EXE set "GIT_EXE=%%G"
exit /b 0

:no_git
echo ERRORE: non trovo Git.
echo Installa/apri GitHub Desktop e rifai accesso, poi riprova.
echo.
pause
exit /b 1

:no_repo
echo ERRORE: questa cartella non contiene .git.
echo Usa questo script dalla cartella GitHub\codex.
echo.
pause
exit /b 1

:pull_error
echo.
echo ERRORE: non posso aggiornare automaticamente.
echo Probabile conflitto o cronologia non lineare. Apri GitHub Desktop.
echo.
pause
exit /b 1

:git_error
echo.
echo ERRORE Git. Controlla connessione/accesso GitHub Desktop.
echo.
pause
exit /b 1
