PERLA1 V248 — RAIN UNIFIED TRANSITION CONTROLLER SAFE

Base reale: PERLA1_V247_RAIN_TEMPORAL_ANGULAR_BALANCE_SAFE_LOCAL.
Build prodotta: PERLA1_V248_RAIN_UNIFIED_TRANSITION_CONTROLLER_SAFE_LOCAL.

Scopo: correggere la causa residua di V247: frontmin, V226 emergency/prewarm, move refill, V235 midfield, V246 bucket balance e V247 angular non devono piu' agire come sorgenti autonome. Tutte le richieste passano attraverso RainUnifiedControllerV248.

Interventi:
- aggiunto controller unico V248 con eventi weather_start, shelter_exit, shelter_edge, stable_covered, angular_turn, stable_outdoor;
- rainQueueRefillV246 ora passa da rainAuthorizeRefillV248 quando V248 e' attiva;
- V226 emergency/prewarm viene assorbito come ramp/forcing controllato e non deve piu' produrre due impulsi diretti nelle transizioni;
- frontmin durante weather_start/shelter_exit/shelter_edge diventa mid/far-first, non near implicita;
- move refill near durante transizioni viene convertito in mid;
- V235 midfield e V246 bucket restano sensori/request producers, governati dal controller;
- sotto copertura stabile il refill viene bloccato dal controller, preservando l'asciutto sotto tettoia;
- angular look-ahead usa richieste mid/far piu' robuste e pre-aged drops per ridurre il ritardo rispetto alla camera;
- boost ottico mid/far esteso senza aumentare near;
- nuovo debug: getRainUnifiedControllerSummaryV248(), downloadRainUnifiedControllerReportV248(), setRainUnifiedControllerV248().

Preservato:
- mappa, fMap, cMap, rainCoveredMap geometry, roadMask, objectBlock, collisioni;
- asset PNG e manifest;
- tetti/roofSegments/V236; torre; pergola; festoni; skybox; sprite placement; audio; high-wall runtime off;
- V234 rain airspace, V235 midfield come sensore, V246 queue/fade/shelter, V247 exposure/angle base.

Nota test: validazione tecnica automatica in ambiente Node/mock; test visivo browser reale non incluso.
