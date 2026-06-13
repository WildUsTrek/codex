PERLA1 V241B — FACE PROJECTION & MATCH RANKING DIAGNOSTIC

Base reale: PERLA1_V241A_FACE_REGISTRY_CANONICALIZATION_DIAGNOSTIC_LOCAL
Build: PERLA1_V241B_FACE_PROJECTION_MATCH_RANKING_DIAGNOSTIC_LOCAL

Scopo:
- Rifinire V241A senza disegnare nulla.
- Aggiungere ranking diagnostico dei match V240A/raw registry -> canonical face.
- Scegliere matchedDominantFaceKey / dominantFaceKey con punteggio, overlap, orientamento, lunghezza, projectionRisk e penalità cap/edge/side.
- Impedire che cap face corte diventino candidate future al draw se esiste una face lunga coerente.

Comandi debug:
- window.__PERLA_DEBUG__.getWorldWallFaceRankingSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceMatchSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceProjectionSummary()
- perlaDownloadColumnFragmentDebugReport()

Il download genera:
- PERLA1_V241B_FACE_MATCH_RANKING_DEBUG_*.json

Vincoli preservati:
- V240A draw OFF
- V241 registry draw OFF
- V241A face draw OFF
- V241B face draw OFF
- nessun update ZBuffer/sprite/rain
- nessun nuovo DDA/overlay/span/continuous wall-run
- nessuna modifica a mappa/collisioni/assets/tetti/torre/reception/bagni/pioggia/auto/skybox
- nessuna cartella patch-only

Test browser reale non eseguito nel container: usare gli stessi punti erba/bath_garden, ruotare lentamente e scaricare 2/3 JSON.
