PERLA1_V158H_ATMOSPHERIC_LANDMARKS_COLOR_REPAIR_SAFE_LOCAL

Base: PERLA1_V158G_SKY_GEOGRAPHIC_LANDMARKS_SAFE_LOCAL, derivata dalla V158F/V157 blindata.
Obiettivo: mantenere presenza geografica, ma correggere l'effetto nero/smog e il cattivo raccordo con pareti lontane in fog.

File principali modificati:
- 01_GIOCO_PRONTO_LOCAL_TEST/index.html
- 01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/sky_panorama_360_v158h.png
- 01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/cloud_layer_soft_v158h.png
- STATUS_PROGETTO_E_DIPENDENZE_PERLA1.txt
- METODO_LAVORO_ANTI_REGRESSIONE_PERLA1.txt
- README_REPACK_V158H.txt
- REPORT_V158H_ATMOSPHERIC_LANDMARKS_COLOR_REPAIR_SAFE.json

Cosa e' stato fatto:
- landmark ridipinti chiari, azzurrati, non continui;
- haze integrato nell'asset, non overlay scuro;
- nuvole schiarite e mantenute come layer indipendente per futuro meteo;
- fog target dei muri lontani allineato al cielo ciano;
- tetti lontani coerenti col target atmosferico dei muri;
- nessun limite alla visibilita' delle pareti.

Preservato:
- map/fMap/roadMask/cMap/objectBlock/collisioni/worldgen;
- roof geometry, roofSegments, gable caps;
- sprite placement;
- ombre, pineta/pergola, laghetto/riva, barca, torre, festoni.

Check dichiarati:
- node --check OK;
- runtime smoke Node OK;
- asset refs 108, missing 0;
- map 150x88;
- sprite runtime 1938;
- roofSegments 2;
- no patch-only folder;
- zip/tar.gz integrity OK nel packaging finale.
