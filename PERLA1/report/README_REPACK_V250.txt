PERLA1 V250 — RAIN NEAR BUCKET SEMANTICS REWORK SAFE

Base reale: PERLA1_V249_RAIN_NEAR_REVEAL_ENVELOPE_SAFE_LOCAL.
Build prodotta: PERLA1_V250_RAIN_NEAR_BUCKET_SEMANTICS_REWORK_SAFE_LOCAL.

Intervento rain-only / near-architecture-only:
- separato spawnBucket/assignedNear da visualBucket;
- la near visuale non dipende piu' dal flag persistente d.near quando V250 e' attiva;
- introdotto near_blend fra near vera e mid;
- de-compattato il volume near con curva depth meno quadratica, laneCount near aumentato e lateral scale near ampliata;
- stile visuale near meno aggressivo, senza toccare mid/far controller;
- aggiunto debug getRainNearBucketSemanticsSummaryV250/download/toggle;
- preservati V248 controller, V249 envelope, angular prefill, mid/far, mappa, asset, tetti, skybox, audio, high-wall runtime-off.

Comandi debug:
window.__PERLA_DEBUG__.getRainNearBucketSemanticsSummaryV250()
window.__PERLA_DEBUG__.downloadRainNearBucketSemanticsReportV250()
window.__PERLA_DEBUG__.setRainNearBucketSemanticsV250(false/true)

Checklist attesa:
- node --check OK;
- asset missing 0;
- PNG modificati 0;
- high-wall runtime-off preservato;
- ZIP/TAR.GZ integri;
- nessuna patch-only folder.
