PERLA1 — README REPACK V183 DISTORTION CONTROLLED HORIZON
================================================================

Build: PERLA1_V183_DISTORTION_CONTROLLED_HORIZON_LOCAL
Base reale: PERLA1_V182_CENTER_RAY_EDGE_DEPROJECTED_HORIZON_LOCAL.zip
Data: 2026-06-10

OBIETTIVO
---------
Correggere il residuo di stiramento orizzontale del fondale V182 senza tornare a parametri scelti a tentativi.
La V183 conserva il paradigma V181/V182:
- fondale continuo;
- campionamento per-colonna;
- centro ray-direction/camera-plane puro;
- nessun yaw gain/damping;
- nessuna segmentazione o crop separato;
- nessun piano/muro prospettico;
- altezza remota stabile.

DIFFERENZA V182 -> V183
----------------------
V182 usava parametri manuali: EDGE_START, EDGE_FULL, EDGE_POWER, EDGE_BLEND_MAX.
V183 disattiva V182 e introduce un mapping distortion-controlled:
- target scelto: PERLA_ENV_HORIZON_MAX_STRETCH_TARGET_V183 = 1.08;
- il codice calcola il punto in cui lo stretch supera la soglia;
- il centro resta ray-direction puro;
- ai bordi la derivata del mapping viene controllata per non superare lo stretch massimo scelto.

FORMULA CONCETTUALE
-------------------
Ray mapping prospettico:
    deltaRay(cameraX) = atan(tan(FOV/2) * cameraX)

Stretch locale rispetto al centro:
    stretch(cameraX) = derivataCentro / derivataLocale
                     = 1 + (tan(FOV/2) * cameraX)^2

Soglia V183:
    targetStretch = 1.08

Punto di inizio correzione:
    edgeStart = sqrt(targetStretch - 1) / tan(FOV/2)

Oltre edgeStart il mapping non viene scelto a mano, ma integrato con derivata costante:
    targetDerivative = tan(FOV/2) / targetStretch

SISTEMI PRESERVATI
------------------
Non sono stati toccati:
- mappa, fMap, roadMask, cMap, objectBlock;
- worldgen e collisioni;
- tetti, roofSegments, gable caps, torre;
- fog globale storico;
- sprite, ombre, pergola, festoni, lago/barca;
- pavimenti, decal, asset PNG;
- struttura launcher, salvo aggiornamento testuale V183.

CHECK ESEGUITI
--------------
- node --check sul JS estratto: OK
- smoke mock drawWorld: OK
- V183 attiva e V182 disattivata: OK
- target stretch: 1.08
- maxStretchRaw rilevato nel mock: 1.81
- maxStretchCorrected rilevato nel mock: 1.08
- asset refs/missing: verificati
- PNG invariati vs V182: verificati
- report/ presente: OK
- patch-only assente: OK
- ZIP/TAR.GZ integrity: OK

NOTA ONESTA
-----------
Non è stato eseguito test browser reale. Il test visivo decisivo resta ruotare davanti alla torre e verificare se il residuo di stiramento laterale risulta ridotto rispetto alla V182 senza perdere la coerenza centrale V181.
