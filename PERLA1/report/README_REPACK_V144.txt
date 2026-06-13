PERLA1 V144 — SHADOW GROUND ANCHOR + PERSPECTIVE TUNE SAFE

Base reale: PERLA1_V143_GROUND_FOOTPRINT_SHADOW_SAFE_LOCAL
Build prodotta: PERLA1_V144_SHADOW_GROUND_ANCHOR_PERSPECTIVE_TUNE_SAFE_LOCAL

Contenuto patch:
- tuning mirato del renderer ombre V143;
- ombra agganciata al piano terreno (`baseY/groundY`) e non al `groundSink`;
- footprint meno lunga, top piatto e fondo arrotondato;
- compressione prospettica verticale in lontananza;
- skip in lontananza quando l’ombra diventerebbe riga/blob fuori prospettiva;
- contact core cached sotto la base per effetto appoggio 3D.

Preservato:
- ancoraggi sprite V143/V142;
- tende lasciate in pace;
- tamerici con lieve lift V142;
- barca esclusa;
- microflora/aghi/pigne/fiori/erbe/cartelli senza ombra runtime;
- PNG, mappa, collisioni, tetti, torre, pergola, festoni, pavimenti, worldgen.

Packaging:
- ZIP completo;
- nessuna cartella SOLO_FILE_DA_SOSTITUIRE / patch-only.

Check:
- node --check OK;
- runtime probe OK;
- shadow scale probe OK;
- asset missing 0;
- PNG modificati 0;
- roofSegments 2.
