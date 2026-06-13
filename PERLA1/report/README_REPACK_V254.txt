# PERLA1 V254 — RAIN NEAR REENTRY COORDINATOR SAFE LOCAL

Base reale: PERLA1_V253A_LAUNCHER_PORT_FIX_SAFE_LOCAL.

Scopo: trasformare le 3 scariche residue della pioggia near in un rientro continuo e controllato.

Intervento:
- aggiunto Rain Near Reentry Coordinator V254 sopra V253;
- intercetta near gia' matura che rientra da hidden/unknown/mid/near_blend dopo copertura;
- crea rampa per-drop con returnPhase continua basata su shelterBlend + exposureWarmupFactor + shelterExitAge;
- clamp progressivo di pixel length per near reentry;
- budget frame/finestra per near reentry, con eccesso convertito a mid_soft;
- tagging visual-only per controller secondario e reservoir hidden/unknown sotto copertura;
- debug dedicato V254 e debug unificato toggleRainUnifiedDebugV254().

Preservato:
- V248 controller core;
- V249 envelope;
- V250 bucket semantics;
- V251 lifecycle diagnostic;
- V252 phase gate;
- V253 near_blend comb breaker;
- spawn/refill/update lifecycle/canKeep;
- mappa/collisioni/assets/tetti/skybox/audio/high-wall.

Comandi debug:
```js
window.__PERLA_DEBUG__.toggleRainUnifiedDebugV254()
// prima chiamata: avvio registrazione completa V251-V254
// seconda chiamata: stop + download JSON unico V254

window.__PERLA_DEBUG__.getRainNearReentryCoordinatorSummaryV254()
window.__PERLA_DEBUG__.downloadRainNearReentryCoordinatorReportV254()
window.__PERLA_DEBUG__.setRainNearReentryCoordinatorV254(false)
window.__PERLA_DEBUG__.setRainNearReentryCoordinatorV254(true)
```
