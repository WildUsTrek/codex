PERLA1 V181 — RAY DIRECTION ENVIRONMENT HORIZON

Base reale: PERLA1_V169_SKYBOX_EDGE_DEPROJECTED_LOCK_SAFE_LOCAL.zip.
Motivo base: V169 e' l'ultima base pulita/continua coerente con il nuovo test; V177/V178/V179/V180 restano tentativi diagnostici/bocciati da non trascinare come codice base.

Intervento:
- Build ID aggiornato a PERLA1_V181_RAY_DIRECTION_ENVIRONMENT_HORIZON_LOCAL.
- Aggiunto renderer PERLA_RAY_DIRECTION_ENV_HORIZON_V181.
- drawBackdrop() usa V181 prima del fallback V169/V163.
- Il panorama e' campionato per colonna con rayDir/cameraPlane: angle = atan2(dirY+planeY*cameraX, dirX+planeX*cameraX).
- Nessun yaw gain, nessun damping, nessuna segmentazione, nessun piano/muro prospettico, nessun crop separato.
- Asset PNG invariati.

Preservato:
map, fMap, roadMask, cMap, objectBlock, worldgen, collisioni, tetti, torre, roofSegments, fog globale, sprite, ombre, pergola, festoni, lago/barca, pavimenti, decal, launcher.

Test eseguiti:
- node --check su JS estratto: OK.
- manifest PNG refs/missing: missing 0.
- PNG invariati vs V169: OK.
- smoke mock drawWorld direzionale: OK.
- ZIP/TAR.GZ integrity: OK.

Nota: test browser reale non eseguito.
