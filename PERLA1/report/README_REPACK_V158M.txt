PERLA1_V158M_LANDMARK_PROFILE_CLARITY_SAFE_LOCAL

Base: PERLA1_V158L_HORIZON_TONAL_GROUNDING_SAFE_LOCAL
Scopo: correggere l'eccesso di sfumatura/haze V158L e rendere i landmark geografici piu' riconoscibili senza regressioni.

Modifiche:
- index.html: build/debug V158M, palette/fog target meno lavati, asset tex 98/99 aggiornati.
- assets/raycast/sky_panorama_360_v158m.png: landmark con profilo leggibile, corpo presente, base sfumata.
- assets/raycast/cloud_layer_soft_v158m.png: layer nuvole separato e leggero.

Non modificato:
- mappa, collisioni, roadMask, fMap, cMap, objectBlock, worldgen;
- tetti geometrici e roofSegments;
- sprite placement, torre, ombre, pineta/pergola, laghetto/riva, barca, festoni;
- visibilita' pareti lontane: nessun culling/distance cap.

Check: vedere REPORT_V158M_LANDMARK_PROFILE_CLARITY_SAFE.json.
