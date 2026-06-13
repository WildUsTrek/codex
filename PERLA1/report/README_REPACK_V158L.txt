PERLA1 V158L — Horizon Tonal Grounding Safe

Base usata: PERLA1_V158K_LANDMARK_SHAPE_READABILITY_SAFE_LOCAL.

Obiettivo:
- correggere l'orizzonte troppo chiaro/latteo della V158K;
- dare piu' grounding cromatico a landmark, muri lontani e tetti lontani;
- non limitare in alcun modo la visibilita' delle pareti.

File principali modificati:
- 01_GIOCO_PRONTO_LOCAL_TEST/index.html
- 01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/sky_panorama_360_v158l.png
- 01_GIOCO_PRONTO_LOCAL_TEST/assets/raycast/cloud_layer_soft_v158l.png
- STATUS_PROGETTO_E_DIPENDENZE_PERLA1.txt
- METODO_LAVORO_ANTI_REGRESSIONE_PERLA1.txt

Preservato:
- map, fMap, roadMask, cMap, objectBlock, collisioni, worldgen;
- geometria tetti, gable, self-depth, roofSegments;
- tower/torre;
- sprite placement, ombre, pineta/pergola, laghetto/riva, barca, festoni;
- nessun culling o distance cap sulle pareti lontane.

Nota:
V158L spinge volutamente un po' il ciano-marino dell'orizzonte basso per verificare
in gioco reale se questa via risolve l'effetto "sagoma che si perde nel latte".
