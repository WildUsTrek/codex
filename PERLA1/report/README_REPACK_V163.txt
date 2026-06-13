PERLA1 V163 — USER MASK ATMOSPHERIC ALPHA SAFE

Base reale: PERLA1_V160_APPROVED_V158M_SKY_RESTORE_SAFE_LOCAL.
Scopo: integrare le sagome disegnate dall'utente, mantenendo una trasparenza atmosferica coerente con V160/V158M.

Cosa e' stato modificato:
- 01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/sky_panorama_360_v163.png
- 01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/cloud_layer_soft_v163.png (rinomina coerente da V160)
- index.html solo per build id / manifest / riferimenti asset V163.

Cosa NON e' stato modificato:
- map, fMap, roadMask, cMap, objectBlock, collisioni, worldgen;
- tetti, torre, sprite placement, ombre, pineta, pergola, laghetto, barca, festoni;
- nessun limite visibilita' pareti, nessun culling/distance cap.

Validazione:
- node --check OK;
- asset refs/missing OK;
- zip/tar integrity OK;
- preview interne in REPORT_V163_SKY_PREVIEWS/.

Nota: il PNG dell'utente era 2048x192; e' stato normalizzato a 4096x384 come richiesto dal runtime.
