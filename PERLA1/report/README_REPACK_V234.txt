PERLA1 V234 — RAIN AIRSPACE LOGIC / CAR ANCHOR SAFE
================================================================
Build: PERLA1_V234_RAIN_AIRSPACE_LOGIC_CAR_ANCHOR_SAFE_LOCAL
Base reale: PERLA1_V233_OVERDRAW_ROLLBACK_STABILITY_LOCAL
Data build locale: 2026-06-11T17:07:13

OBIETTIVO
---------
V234 parte dalla V233 stabile e non riaccende i draw extra V228/V229/V230.
La patch introduce solo due correzioni chirurgiche:
1. ripristino della pioggia sopra muri bassi/siepi outdoor tramite logica invisibile/no-draw rain-only;
2. correzione delle auto/parcheggio con lift visivo render-time solo parked_car/texture auto.

INTERVENTI TECNICI
------------------
- Aggiunte costanti V234: PERLA_V234_RAIN_AIRSPACE_LOGIC_CAR_ANCHOR_SAFE, PERLA_WEATHER_V234_MODE, PERLA_V234_RAIN_AIRSPACE_NO_WALL_DRAW, limiti low-wall airspace e car lift.
- projectRainPointV222 ora conserva wx/wy nel punto proiettato, così la rain visibility può ragionare sulla cella mondo reale senza ricostruzioni screen-space.
- Aggiunto isRainOutdoorLowWallAirspaceCellV234(ix,iy,drawStats): autorizza solo muri bassi outdoor/siepi, esclude edifici moderni, torre, muri alti, rainCoveredMap e cMap.
- canSpawnRainAirAtV225/canKeepRainDropAtV225 usano la logica V234 per consentire spawn/keep sopra muri bassi outdoor se z supera altezza muro + clearance.
- rainPointVisibleV222 mantiene priorità assoluta a CeilingDepthBuffer/canopy/indoor e poi autorizza rainOutdoorLowWallAirspaceVisibleV234 prima dell'occlusione layer V227.
- Aggiunto carVisualAnchorLiftV234(sprite,spSize,transY,drawStats): lift render-time solo auto/parcheggio, senza modificare dati sprite, groundSink, collisioni, objectBlock o asset.
- Aggiornati title/h2/loading/launcher a V234 e debug window.__PERLA_DEBUG__ con helper e costanti V234.

PRESERVAZIONI OBBLIGATORIE
--------------------------
- PERLA_V233_DISABLE_FAR_WALL_SPAN_DRAW resta true.
- PERLA_V233_DISABLE_HEIGHT_STEP_FACE_DRAW resta true.
- PERLA_V233_DISABLE_CONTINUOUS_WALL_RUN_DRAW resta true.
- Nessun draw extra muri è stato riattivato.
- PNG/asset non modificati.
- Mappa, collisioni, worldgen, roadMask, objectBlock, roof geometry, torre, skybox, audio/meteo generale preservati.

VALIDAZIONE VISIVA RICHIESTA
----------------------------
- Rain/storm: la pioggia deve tornare visibile sopra siepi/muri bassi outdoor.
- Rain/storm: niente pioggia dentro reception/bagni o sotto bar/yoga/sala giochi.
- Auto parcheggio: non devono più sembrare sbucare da sotto il muro, senza sembrare sospese.
- Stabilità V233: niente ritorno di fasce/glitch/texture schiacciate dei wall-run.

NOTA ONESTA
-----------
I check statici sono eseguibili in container; il test browser/visivo reale resta obbligatorio lato utente.
