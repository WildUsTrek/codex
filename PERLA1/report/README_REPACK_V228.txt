PERLA1 V228 — FAR WALL SPAN AND SPRITE OCCLUSION DISTANCE

Base reale: PERLA1_V227_LAYERED_WALL_OCCLUSION_HEIGHT_FIX_LOCAL.

Obiettivo:
- stabilizzare i muri alti lontani dietro muri bassi tramite far-wall spans continui;
- raggruppare second-hit wall layer per texture/side/altezza/linea;
- recuperare colonne sottili/intermittenti dentro span coerenti;
- evitare sparizioni a metà parete in angoli grazing/paralleli;
- garantire wallOcclusionMaxDist > spriteMaxDrawDist, così gli sprite non restano visibili oltre occlusori mancanti.

File modificati:
- 01_GIOCO_PRONTO_LOCAL_TEST/index.html
- AVVIA_GIOCO_SERVER_POWERSHELL.ps1
- AVVIA_GIOCO_WINDOWS_SENZA_PYTHON.bat
- report/STATUS_PROGETTO_E_DIPENDENZE_PERLA1.txt
- report/METODO_LAVORO_ANTI_REGRESSIONE_PERLA1.txt
- report/REPORT_V228_FAR_WALL_SPAN_AND_SPRITE_OCCLUSION_DISTANCE_LOCAL.json

Sistemi preservati:
- mappa/collisioni/worldgen/roadMask/objectBlock;
- asset PNG;
- tetti/roofSegments/canopy;
- audio/meteo;
- V223 bath authority;
- V226 camera rain volume;
- V227 wall-layer base.

Nota: test browser reale non eseguito in ambiente container. Validare nei punti screenshot angolo 1/angolo 2, sprite dietro siepi e sprite lontani dietro muri.
