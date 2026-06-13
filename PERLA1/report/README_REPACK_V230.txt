PERLA1 V230 — CONTINUOUS WALL RUN PROJECTION CLIP

Base reale: PERLA1_V229B_HEIGHT_STEP_CONST_GUARD_LOCAL.

Obiettivo: chiudere il residuo del Lavoro 1. V228/V229B miglioravano i muri alti dietro muri bassi, ma li ricostruivano ancora da second-hit/height-step locali intermittenti. V230 aggiunge ContinuousWallRunsV230: pareti continue derivate da map + wallHeightMap, con edge extraction per muri spessi 2+ celle, proiettate come superfici continue e clippate dietro il muro basso davanti.

Preservato: V229 sprite occlusion ground seal, V228 wall occlusion distance > sprite distance, V226 camera rain volume, V223 bath authority, mappa/collisioni/worldgen/roadMask/objectBlock/asset/tetti/audio/skybox.

Test decisivi: screenshot muro alto continuo dietro muro basso; muro spesso 2+ celle; angoli grazing; sprite seal; pioggia/tettoie/bagni.
