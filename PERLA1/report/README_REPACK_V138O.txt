PERLA1 V138O — MICROFLORA FOOTPRINT SAFE
Base reale: PERLA1_V138N_SOLID_FOOT_FLOWER_SPACING_SAFE
Patch: PERLA1_V138O_MICROFLORA_FOOTPRINT_SAFE

Scopo:
- correggere il problema storico per cui erba/fiori/aghi/pigne possono avere il centro su erba ma il billboard visivo invade terra/strada/piazzole;
- applicare un footprint-safe cleanup su microflora: non basta piu' il centro su tile erbosa, deve essere coerente anche il piccolo raggio attorno allo sprite;
- spostare leggermente verso l'interno dell'erba quando possibile, rimuovere solo quando non esiste una posizione sicura vicina;
- non toccare PNG, torre, tetti, tettoie, mappa, collisioni principali o asset artistici.

Risultato probe runtime mock:
- microflora controllata: 902
- gia' sicura: 526
- spostata: 354
- rimossa: 22
- roofSegments: 2
- sprites finali probe: 2172

Regole patch:
- microflora interessata: grass/fiori/pigne/aghi/grass variants;
- safe surfaces: erba/pineta/fasce verdi e secret flower field semantico;
- esclusi: strada, sabbia, mare, terra casa, sentieri, roadMask, cMap, objectBlock, bar/bath/secret paths;
- nessun clipping runtime: il render resta stabile, il cleanup agisce sul placement.

File diagnostico: REPORT_V138O_MICROFLORA_FOOTPRINT_SAFE.json
