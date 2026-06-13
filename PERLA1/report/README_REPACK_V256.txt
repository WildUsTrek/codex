PERLA1 V256 — RAIN OPEN SHELTER VISIBILITY RESTORE SAFE LOCAL

Base reale: PERLA1_V255_RAIN_RESERVOIR_RELEASE_SMOOTHER_SAFE_LOCAL
Build: PERLA1_V256_RAIN_OPEN_SHELTER_VISIBILITY_RESTORE_SAFE_LOCAL
Data: 2026-06-12

Questa build corregge una regressione introdotta da V255: sotto copertura stabile la pioggia poteva sparire completamente attraverso porte o tettoie aperte. Il fix non riapre spawn/refill/canKeep e non modifica mappe, cMap, rainCoveredMap, rainOpenSkyMap, tetti o asset.

Comandi debug principali:
- window.__PERLA_DEBUG__.toggleRainUnifiedDebugV256()
- window.__PERLA_DEBUG__.getRainOpenShelterVisibilitySummaryV256()
- window.__PERLA_DEBUG__.downloadRainOpenShelterVisibilityReportV256()
- window.__PERLA_DEBUG__.setRainOpenShelterVisibilityRestoreV256(false/true)

Criterio di test reale:
1. sotto tettoia aperta: vicino asciutto, pioggia visibile oltre bordo;
2. porta/soglia: interno asciutto, fuori porta pioggia visibile;
3. interno chiuso: niente pioggia dentro;
4. uscita tettoia: non devono tornare i tre scatti forti;
5. outdoor stabile: rain normale piena.

Nota: test browser/Windows reale demandato all'utente; in container sono stati eseguiti check statici/VM.
