PERLA1_V158G_SKY_GEOGRAPHIC_LANDMARKS_SAFE_LOCAL

Base: PERLA1_V158F_SKY_ATMOSPHERE_MINIMAL_PANORAMA_SAFE_LOCAL, derivata da V157 reale blindata.

Obiettivo:
Aggiungere presenza geografica leggibile allo skybox minimalista V158F senza tornare alle bande/fondali/cartoncini delle versioni precedenti.

Modifiche:
- nuovo assets/raycast/sky_panorama_360_v158g.png;
- nuovo assets/raycast/cloud_layer_soft_v158g.png;
- manifest texture invariato come slot: 98 panorama, 99 cloud layer;
- build ID aggiornato a V158G;
- debug V158G coerente;
- documentazione aggiornata.

Preservato:
- nessun limite alla visibilita' delle pareti lontane;
- nessun culling/distance cap;
- nessuna modifica a map, fMap, roadMask, cMap, objectBlock, collisioni, worldgen;
- tetti V149 / roofSegments=2;
- sprite placement, ombre, pineta/pergola, laghetto/riva, barca, torre, festoni.
