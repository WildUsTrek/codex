PERLA1 V225B — RAIN CLIP NULL GUARD LOCAL

Base reale: PERLA1_V225_RAIN_WALL_SPAN_CLIP_AIRSPACE_LOCAL
Scopo: hotfix chirurgico del crash runtime segnalato dall'utente:
Uncaught TypeError: can't access property "x", b is null in rainLerpPointV225.

Diagnosi:
Il nuovo clipping V225 poteva ricevere endpoint null quando projectRainPointV222 restituiva null per un sample fuori camera/schermo, ma clipRainSegmentPartialV225 provava comunque a interpolare visible/hidden.

Interventi:
- aggiunta rainPointFiniteV225(p);
- rainLerpPointV225 ora ritorna null se gli endpoint non sono validi;
- clipRainSegmentPartialV225 scarta segmenti con endpoint null/non finiti invece di crashare;
- draw loop rain ha guardia dopo clipping e dopo clamp;
- clampRainSegmentPixelLengthV224 ha guardia invalid endpoint;
- aggiunti debug counter V225B: rainClipNullGuardV225B, rainSegmentsRejectedInvalidEndpointV225B, rainSegmentsRejectedInvalidAfterClipV225B, rainSegmentsRejectedInvalidClampV225B.

Preservato:
- V225 wall span clip/airspace;
- V224 LOD/refill/motion compensation;
- V223 bath authority/bath_garden outdoor;
- mappa, collisioni, worldgen, tetti, sprite, asset, audio, skybox.

Check statici eseguiti:
- node --check sul JS estratto: OK;
- asset refs invariati;
- nessuna modifica PNG;
- ZIP/TAR.GZ integrity da verificare nel packaging finale.

Nota onesta:
Non è stato eseguito test browser/visivo nel container. Questa build corregge il crash da endpoint null e va testata nello stesso punto in cui V225 crashava.
