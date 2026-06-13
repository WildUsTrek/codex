PERLA1 V253 — RAIN NEAR BLEND COMB BREAKER SAFE LOCAL

Base reale: PERLA1_V252_RAIN_NEAR_PHASE_DESYNCHRONIZATION_SAFE_LOCAL.

Scopo: correggere il pettine generato da near_blend senza toccare spawn, refill, controller, lifecycle, canKeep, mappa, collisioni, asset, tetti, skybox o audio.

Interventi:
- near_blend non e' piu' destinazione automatica e illimitata delle candidate near soppresse da V252;
- cap near_blend per evento/meteo/copertura;
- eccesso near_blend convertito a mid_soft visuale;
- near_blend residua ammorbidita e jitterata in modo deterministico per rompere geometria a pettine;
- debug V253 dedicato;
- debug unificato V253 start/stop: toggleRainUnifiedDebugV253();
- launcher Windows aggiornato per tentare chiusura automatica dei vecchi server PERLA1 sulla porta 8000.

Comandi debug principali:
window.__PERLA_DEBUG__.getRainNearBlendCombBreakerSummaryV253()
window.__PERLA_DEBUG__.downloadRainNearBlendCombBreakerReportV253()
window.__PERLA_DEBUG__.setRainNearBlendCombBreakerV253(false/true)
window.__PERLA_DEBUG__.toggleRainUnifiedDebugV253()

Uso debug unificato:
1) window.__PERLA_DEBUG__.toggleRainUnifiedDebugV253()  // avvia e abilita switch
2) riprodurre raffiche/pettine
3) window.__PERLA_DEBUG__.toggleRainUnifiedDebugV253()  // stop + download JSON completo
