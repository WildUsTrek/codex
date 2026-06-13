@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title CODEX - 02 Salva progetto su GitHub

echo ============================================================
echo  CODEX / PERLA1 - SALVA PROGETTO SU GITHUB
echo ============================================================
echo.

call :find_git
if not defined GIT_EXE goto no_git

if not exist ".git" goto no_repo

for /f "delims=" %%B in ('"%GIT_EXE%" rev-parse --abbrev-ref HEAD 2^>nul') do set BRANCH=%%B
if not defined BRANCH set BRANCH=main

"%GIT_EXE%" status --short

echo.
echo Preparo il salvataggio...
"%GIT_EXE%" add -A
if errorlevel 1 goto git_error

for /f "delims=" %%S in ('"%GIT_EXE%" status --porcelain') do set HAS_CHANGES=1
if not defined HAS_CHANGES (
  echo Nessuna modifica da salvare.
  echo Provo comunque a sincronizzare con GitHub...
  "%GIT_EXE%" pull --rebase --autostash origin %BRANCH%
  if errorlevel 1 goto pull_error
  "%GIT_EXE%" push origin %BRANCH%
  if errorlevel 1 goto push_error
  echo.
  echo OK: era gia' tutto sincronizzato.
  echo.
  pause
  exit /b 0
)

set MSG=Aggiorna progetto Codex PERLA1 - %date% %time%
echo Creo commit: %MSG%
"%GIT_EXE%" commit -m "%MSG%"
if errorlevel 1 goto commit_error

echo.
echo Allineo eventuali modifiche remote...
"%GIT_EXE%" pull --rebase --autostash origin %BRANCH%
if errorlevel 1 goto pull_error

echo.
echo Carico su GitHub...
"%GIT_EXE%" push origin %BRANCH%
if errorlevel 1 goto push_error

echo.
echo OK: progetto salvato su GitHub.
echo Ora puoi aprirlo dagli altri dispositivi con Pull/Aggiorna.
echo.
pause
exit /b 0

:find_git
rem Metodo reale Windows:
rem 1) usa git dal PATH, se esiste;
rem 2) altrimenti usa il git.exe incluso in GitHub Desktop.
rem Non usare un percorso hard-coded con il nome utente.
where git >nul 2>nul
if not errorlevel 1 (
  for /f "delims=" %%G in ('where git') do if not defined GIT_EXE set "GIT_EXE=%%G"
)
if defined GIT_EXE exit /b 0
rem PowerShell gestisce meglio app-* rispetto a dir/cmd con wildcard quotati.
for /f "delims=" %%G in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$root=Join-Path $env:LOCALAPPDATA 'GitHubDesktop'; $apps=Get-ChildItem -LiteralPath $root -Directory -Filter 'app-*' -ErrorAction SilentlyContinue; foreach($app in $apps){$candidate=Join-Path $app.FullName 'resources\app\git\cmd\git.exe'; if(Test-Path -LiteralPath $candidate){Write-Output $candidate; break}}" 2^>nul') do if not defined GIT_EXE set "GIT_EXE=%%G"
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

:commit_error
echo.
echo ERRORE durante il commit. Apri GitHub Desktop per vedere il dettaglio.
echo.
pause
exit /b 1

:pull_error
echo.
echo ERRORE: GitHub contiene modifiche che non posso integrare automaticamente.
echo Apri GitHub Desktop: probabilmente serve risolvere un conflitto.
echo.
pause
exit /b 1

:push_error
echo.
echo ERRORE: non sono riuscito a caricare su GitHub.
echo Controlla connessione e accesso in GitHub Desktop.
echo.
pause
exit /b 1

:git_error
echo.
echo ERRORE Git. Apri GitHub Desktop per dettagli.
echo.
pause
exit /b 1
