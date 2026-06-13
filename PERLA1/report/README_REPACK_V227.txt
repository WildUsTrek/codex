PERLA1 V227 — LAYERED WALL OCCLUSION HEIGHT FIX

Base reale: PERLA1_V226_RAIN_CAMERA_VOLUME_WORLD_OCCLUSION_LOCAL.

Scopo:
- correggere il modello di occlusione verticale: un muro basso non deve tagliare muri o sprite piu' alti dietro;
- rendere la pioggia dipendente dai layer della scena, non da scorciatoie z>1;
- preservare V226 camera rain volume, V224 LOD/refill, V223 bath authority e open canopy.

Interventi:
- aggiunti WallLayerBufferV227 e WallOcclusionRangesV227;
- wallcasting con raccolta limitata multi-hit fino a 3 layer per colonna;
- render delle porzioni alte di muri lontani che emergono sopra muri bassi davanti;
- sprite clipping parziale per fasce verticali invece di ZBuffer full-stripe;
- rain visibility basata su ceiling/indoor prima, poi wall layers;
- airspace rain limitata a muri outdoor bassi/hedge, non edifici moderni/reception/bagni;
- debug V227 aggiunto.

Non toccati volutamente:
- asset PNG;
- mappa/collisioni/roadMask/objectBlock;
- skybox/fondale;
- audio;
- tetti/roof budget;
- bath authority V223;
- camera volume V226.

Nota test:
Check statici eseguiti in ambiente container; il test visivo browser reale resta necessario.
