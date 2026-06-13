PERLA1 V226 — RAIN CAMERA VOLUME WORLD OCCLUSION LOCAL

Base reale: PERLA1_V225B_RAIN_CLIP_NULL_GUARD_LOCAL
Build prodotta: PERLA1_V226_RAIN_CAMERA_VOLUME_WORLD_OCCLUSION_LOCAL
Data: 2026-06-11

Scopo:
- consolidare la pioggia world-space dopo V225B;
- impedire al player di “seminare” la pioggia correndo o ruotando;
- eliminare fallback near concentrati che potevano produrre colonne d’acqua;
- correggere il concetto di occlusione muri: ZBuffer solo ausiliario, decisione basata anche su quota/altezza reale del muro;
- mantenere V223 bath authority e V224 distance LOD/bucket rendering;
- non toccare mappa, collisioni, tetti, sprite, asset, audio, skybox.

Interventi tecnici:
1. Aggiunto Camera Rain Volume V226: le gocce sono distribuite in lane/depth relative alla camera e convertite ogni frame in world-space.
2. Respawn rain riscritto per non usare fallback concentrato davanti al player. Se il respawn non trova posizione valida, la goccia resta inattiva e viene riprovata.
3. Refill V224 aggiornato con soglie basate sui segmenti realmente disegnati nel frame precedente.
4. Emergency prewarm V226 senza cooldown quando la vista resta sotto-riempita.
5. Occlusione muri aggiornata: rainPointOccludedBySolidHeightV226 usa ZBuffer solo come profondità ausiliaria e controlla la quota z contro altezza stimata muro.
6. Screen clipping robusto con clipLineSegmentToScreenRectV226, per permettere alle gocce vicine di entrare dal bordo alto dello schermo.
7. Debug V226 aggiunto: rainRendererModeV226, rainVisibleSegmentsLastFrameV226, rainEmergencyPrewarmV226, rainFullColumnZBufferOcclusionV226=false, rainZBufferAuxOnlyV226=true, rainNoConcentratedFallbackV226=true.

Preservato:
- V223 bath_garden outdoor e bath_main autorità porta reale bagni;
- bar/yoga/sala giochi open canopy;
- V224 LOD near/mid/far e bucket rendering;
- V225B guardie anti-null;
- tetti, tettoie, cMap, roofSegments, mappa, collisioni, sprite, asset PNG, audio, skybox, minimappa, controlli mobile.

Check eseguiti in ambiente container:
- node --check su JS estratto: OK;
- asset scan: eseguito nel report JSON;
- integrità ZIP/TAR.GZ: da eseguire dopo packaging finale.

Nota onesta:
Non è stato eseguito test browser/visivo reale nel container. La validazione decisiva resta in gioco: rotazione brusca, corsa, siepi/muri cespugliosi, tettoia yoga, bath_garden/bagni.
