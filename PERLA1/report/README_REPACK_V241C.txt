PERLA1 V241C — FACE DRAWABILITY ELIGIBILITY DIAGNOSTIC
================================================================

Build: PERLA1_V241C_FACE_DRAWABILITY_ELIGIBILITY_DIAGNOSTIC_LOCAL
Base reale: PERLA1_V241B_FACE_PROJECTION_MATCH_RANKING_DIAGNOSTIC_LOCAL
Data repack: 2026-06-12T01:58:53.748561Z

SCOPO
-----
Patch diagnostica, non visuale. V241C non disegna muri e non aggiorna ZBuffer/sprite/rain.
Aggiunge uno strato sopra V241B per separare:

- dominantExplanatoryFace: faccia reale che spiega meglio la geometria anche se grande/edge/slab;
- fullFaceDrawable: faccia intera teoricamente sicura per un futuro micro-draw;
- clippedSpanDrawable: faccia intera non sicura, ma con eventuali safeInteriorSpans interni diagnosticati;
- explanatory_only_*: faccia utile per spiegare la scena ma non eleggibile al draw futuro.

COMANDI DEBUG
-------------
- window.__PERLA_DEBUG__.getWorldWallFaceDrawabilitySummary()
- window.__PERLA_DEBUG__.getWorldWallSafeSpanSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceMatchSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceRankingSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceProjectionSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceRegistrySummary()
- perlaDownloadColumnFragmentDebugReport()

DOWNLOAD DEBUG
--------------
- PERLA1_V241C_FACE_DRAWABILITY_DEBUG_*.json

VINCOLI PRESERVATI
------------------
- V240A draw OFF
- V241 registry draw OFF
- V241A face draw OFF
- V241B face match draw OFF
- V241C draw OFF
- ZBuffer update OFF
- sprite occlusion update OFF
- rain occlusion update OFF
- nessun nuovo DDA
- nessun overlay
- nessun continuous wall-run
- nessuna modifica a map/fMap/cMap/roadMask/objectBlock/collisioni/assets/skybox/tetti/torre/reception/bagni/pioggia/auto/pergola/festoni

TEST CONSIGLIATI
----------------
Nei punti erba e bath_garden:
1. ruotare lentamente;
2. chiamare getWorldWallFaceDrawabilitySummary();
3. chiamare getWorldWallSafeSpanSummary();
4. scaricare 2/3 JSON con perlaDownloadColumnFragmentDebugReport();
5. verificare che erba mantenga una main_front_face pulita e che bath_garden distingua grossa faccia explanatory da full/clipped drawability.
