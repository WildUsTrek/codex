# PERLA1 V213 — Door Rain Ceiling Cap + Early Fullscreen

Build: `PERLA1_V213_DOOR_RAIN_CEILING_CAP_EARLY_FULLSCREEN_LOCAL`
Base reale: `PERLA1_V212_DOOR_RAIN_ASPECT_LOCK_EARLY_FULLSCREEN_LOCAL`

## Scopo

Correggere i due residui visivi della pioggia vista attraverso la porta senza ripetere i tentativi falliti di calcolo perfetto di `yTop`:

1. Da indoor profondo la colonna di pioggia risultava ancora troppo alta.
2. Vicino alla porta il full-screen rain partiva troppo tardi e rimaneva una fascia schiacciata.

## Strategia V213

- Mantiene il renderer dedicato `drawDoorRainPlaneWorldSpaceV210`.
- Non ritorna al vecchio path `rainBuffer + ctx.clip + drawImage` per la porta.
- Introduce `perlaWeatherDoorRainCeilingCapYV213()`: il soffitto/architrave/muro superiore gia' renderizzato diventa limite alto autorevole per il door rain plane.
- Usa `CeilingDepthBuffer`, `CeilingColumnHasDepth`, `ZBuffer`, `WallTopBuffer`, `WallBottomBuffer`; se il roof budget non espone buffer sufficienti, usa un fallback architrave dichiarato nel debug.
- Rende piu' autorevole il full-screen vicino soglia con `v213AuthoritativeOk` e `v213NearAuthority`.

## File modificati

- `01_GIOCO_PRONTO_LOCAL_TEST/index.html`
- `AVVIA_GIOCO_SERVER_POWERSHELL.ps1`
- `AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat`
- `report/METODO_LAVORO_ANTI_REGRESSIONE_PERLA1.txt`
- `report/STATUS_PROGETTO_E_DIPENDENZE_PERLA1.txt`

## Check

- node --check: OK
- PNG manifest refs: 108
- Missing PNG: 0
- PNG modificati rispetto a V212: 0
- Cartella patch-only: assente
- Renderer dedicato porta senza `ctx.clip`, senza `drawImage`, senza chiamata a `perlaCompositeRainBufferV201`.

Nota: non e' stato dichiarato test browser/visivo reale.
