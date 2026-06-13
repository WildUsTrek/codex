PERLA1 V244 — HIGH WALL DRAW ROLLBACK DEBUG ONLY

Base reale usata:
- PERLA1_V241C_FACE_DRAWABILITY_ELIGIBILITY_DIAGNOSTIC_LOCAL

Scopo:
- Rollback sicuro e revisionato di tutti i tentativi visuali di disegno dei muri alti dietro muri bassi.
- Rimuovere dalla build finale il draw sperimentale V242, V242A e V243.
- Conservare solo la diagnostica utile V241/V241A/V241B/V241C: registry, face registry, ranking, drawability/safe spans.
- Nessun draw muri alti extra, nessun update ZBuffer/sprite/rain, nessun nuovo DDA, nessun overlay, nessun continuous wall-run.

Decisione operativa:
- Il cantiere visuale dei muri alti è chiuso/abbandonato per ora.
- Le build V242/V242A/V243 restano solo come prove fallite/storiche fuori da questa build, non incluse nella pipeline V244.
- V244 torna al comportamento sicuro pre-draw, con debug ancora disponibili per eventuali audit futuri.

Debug conservati:
- window.__PERLA_DEBUG__.getWorldWallRegistrySummary()
- window.__PERLA_DEBUG__.getWorldWallRegistryProjectionSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceRegistrySummary()
- window.__PERLA_DEBUG__.getWorldWallFaceProjectionSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceRankingSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceMatchSummary()
- window.__PERLA_DEBUG__.getWorldWallFaceDrawabilitySummary()
- window.__PERLA_DEBUG__.getWorldWallSafeSpanSummary()
- perlaDownloadColumnFragmentDebugReport()

Output debug:
- PERLA1_V244_HIGH_WALL_ROLLBACK_DEBUG_*.json

Vincoli preservati:
- mappa/collisioni/assets non modificati
- tetti/torre/reception/bagni/pioggia/auto/skybox non toccati
- PNG non modificati
- patch-only assente
