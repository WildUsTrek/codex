PERLA1 V215 — Door Rain Solid Ceiling Occluder
================================================

Build prodotta: PERLA1_V215_DOOR_RAIN_SOLID_CEILING_OCCLUDER_LOCAL
Base reale: PERLA1_V214_DOOR_RAIN_DRAW_ORDER_CEILING_REPLAY_LOCAL

Diagnosi reale
--------------
V214 ha fallito per due motivi concreti:
1. replayava segmenti ceiling/canopy solo se raccolti/intersecanti, quindi non garantiva una cover piena.
2. se la pioggia passava in modalità global/fullscreen threshold mentre il player era ancora covered/indoor, la cover porta non era autorevole.

Intervento V215
---------------
- Aggiunto `PERLA_V215_DOOR_RAIN_SOLID_CEILING_OCCLUDER`.
- Aggiunto `drawDoorRainSolidCeilingCoverV215(...)`.
- La funzione viene chiamata dopo `drawWeatherOverlayV190(...)` e dopo il replay V214.
- Non modifica `yTop`/`yBottom` della pioggia.
- Disegna fisicamente una cover piena in draw-order sopra la pioggia quando:
  - meteo rain/storm;
  - player ancora covered;
  - descriptor porta attivo;
  - rain door o threshold/global rain e' stata disegnata.
- Il bordo inferiore della cover viene derivato dal `WallTopBuffer` corrente; se non basta, usa fallback controllato.
- Il colore/fog viene dalla pipeline attuale `roofSoffitVisibleColorV109(...)` + `roofPremixedFogColorV106(...)`.

Checklist logica
----------------
1. Mondo/muri/soffitto/tetti prima.
2. Rain dopo.
3. Solid cover subito dopo la rain.
4. Cover non dipendente da segmenti V214 come meccanismo primario.
5. No nuovo yTop tuning, no vecchio overlay door rain, no asset o mappa toccati.

Check tecnici eseguiti
----------------------
- node --check: OK.
- Asset manifest PNG: 108/108 presenti.
- PNG raycast: invariati rispetto a V214.
- Nessuna cartella patch-only.
- UI/build aggiornata a V215.

Nota onesta
-----------
Non e' stato eseguito test browser/visivo reale in questa sessione. La patch corregge il difetto architetturale evidente di V214: la cover ora e' solida e draw-after-rain anche per threshold/global rain indoor.
