PERLA1 V155 — LAKE GRASS EATS SAND BLEND SAFE

Base reale: PERLA1_V154_LAKE_GRASS_BLEND_UNDER_PINES_FINAL_SAFE_LOCAL.

Scopo:
- chiudere il difetto della transizione sabbia/erba del laghetto ancora troppo a scalini;
- mantenere lo specchio d'acqua V153/V154 approvato;
- far aggredire visivamente l'erba dentro la sabbia con una maschera sub-tile ellittica, invece di colorare quadrati/ring a celle;
- mantenere colori coerenti sotto/prossimo ai pini e agli sprite bloccanti, senza modificare objectBlock o collisioni.

Interventi:
- aggiunti helper V155 per colore erba/pineta esterno campionato radialmente;
- sostituita la logica sabbia->erba del lago in applySecretLakeShoreSubTileV152 con maschera V155 grass-eats-sand;
- ridotte le tinte cell-level di lakeOuter/lakeGrass per eliminare l'alone a quadrati;
- ridotta la vecchia decal lake_grass_sand_soft_v78 per non reintrodurre blockiness;
- nessun PNG modificato, nessun nuovo sprite, nessuna cartella patch-only.

Preservati:
- acqua lago V153;
- barca V153/V154;
- tetti V149;
- performance pineta V148;
- pergola, ombre, torre, festoni, statua, sassi, fiori;
- mappa, fMap, roadMask, cMap, objectBlock, collisioni e worldgen.
