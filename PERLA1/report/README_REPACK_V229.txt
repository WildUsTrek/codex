PERLA1 V229 — HEIGHT STEP WALL FACES + SPRITE OCCLUSION GROUND SEAL

Base reale: PERLA1_V228_FAR_WALL_SPAN_AND_SPRITE_OCCLUSION_DISTANCE_LOCAL
Build prodotta: PERLA1_V229_HEIGHT_STEP_WALL_FACES_SPRITE_SEAL_LOCAL

Scopo:
1) Correggere muri alti spezzati dietro muri bassi usando facce height-step derivate da map + wallHeightMap.
2) Correggere leakage della base degli sprite lontani dietro muri con un ground seal solo sulla maschera di occlusione, senza toccare posizione, altezza, anchor, groundSink, scale o asset sprite.

Interventi principali:
- Aggiunti HeightStepFacesV229 e HeightStepRunsV229.
- buildHeightStepFacesV229() costruisce facce verticali dove una cella solida alta confina con una cella solida più bassa.
- drawHeightStepFacesV229() disegna la fascia alta emergente zLow..zHigh sopra il muro basso davanti, aggiungendola anche a WallOcclusionRanges.
- V228 FarWallSpanGroups resta fallback/supporto.
- Aggiunto spriteOcclusionSealMarginV229(): sigilla solo il clipping sprite dietro muro con margine basso prudente/distanza, senza modificare sprite reali.

Preservato:
- mappa, collisioni, roadMask, objectBlock, worldgen logico;
- asset PNG;
- tetti, roof, canopy, skybox, audio, meteo;
- V223 bath authority / bath_garden outdoor / open canopy;
- V226 camera rain volume;
- V228 wall occlusion distance > sprite distance.

Nota test:
Sono stati eseguiti check statici e integrità, non test browser/visivo reale nel container.
