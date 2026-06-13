PERLA1 V253A - LAUNCHER PORT FIX SAFE

Base reale: PERLA1_V253_RAIN_NEAR_BLEND_COMB_BREAKER_SAFE_LOCAL.

Scopo: microfix esclusivamente launcher Windows/PowerShell.

Problema corretto:
- PowerShell interpretava in stringhe `$Port:` e `$owner:` come riferimenti variabile/scope non validi.
- Correzione: uso esplicito `${Port}:` e `${owner}:`.

Non toccato:
- 01_GIOCO_PRONTO_LOCAL_TEST/index.html
- logica gioco
- rain V253
- asset
- mappa
- collisioni
- tetti
- skybox
- audio

File modificati:
- AVVIA_GIOCO_SERVER_POWERSHELL.ps1
- AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat solo etichetta/titolo
- report/README_REPACK_V253A_LAUNCHER_PORT_FIX.txt

Check:
- ricerca pattern PowerShell `$Var:` residui nel PS1: nessuno.
- asset invariati.
- zip/tar completi.
