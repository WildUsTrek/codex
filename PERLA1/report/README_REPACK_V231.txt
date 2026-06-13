PERLA1 V231 — CONTINUOUS WALL RUN RASTER TEXTURE SAFE

Base reale: PERLA1_V230_CONTINUOUS_WALL_RUN_PROJECTION_CLIP_LOCAL
Build prodotta: PERLA1_V231_CONTINUOUS_WALL_RUN_RASTER_TEXTURE_SAFE_LOCAL

Obiettivo:
- Rendere sicuro il renderer dei continuous wall-run introdotto in V230.
- Eliminare colonne verticali isolate lontane.
- Evitare che torre e renderer speciali vengano ridisegnati dal pass generico.
- Correggere il texture mapping verticale dei wall-run emergenti: srcY/srcH derivano dalla porzione realmente visibile, non dalla texture intera schiacciata.

Interventi:
- Aggiunti flag/costanti V231.
- drawContinuousWallRunsV230 aggiornato con comportamento V231 rasterizzato.
- Aggiunti helper isSpecialWallRunRendererV231, continuousWallRunScreenSpanV231, continuousWallRunTextureSliceV231.
- Esclusione tower/tower-like runs dal renderer generico; restano al renderer torre dedicato.
- Mantenuti V228 wall distance > sprite distance, V229 sprite seal, V230 continuous runs.

Preservato:
- mappa/collisioni/worldgen/roadMask/objectBlock;
- asset PNG;
- sprite placement/groundSink/anchor/scale;
- tetti/roof/canopy;
- skybox/fondale/audio/meteo;
- bath authority e camera rain volume.

Nota: test statici eseguiti; test browser/visivo reale demandato.
