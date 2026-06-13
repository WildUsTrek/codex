# PERLA1 V255 — RAIN RESERVOIR RELEASE SMOOTHER SAFE

Base reale: `PERLA1_V254_RAIN_NEAR_REENTRY_COORDINATOR_SAFE_LOCAL`.

Obiettivo: eliminare i tre scatti residui non più generati dalla near piena, ma dal rilascio a onde del corpo visibile della pioggia (`mid` / `near_blend` / `mid_soft`) dopo tettoia/copertura.

Intervento: introdotto `Rain Reservoir Release Smoother V255` come layer visuale finale dopo V254. La patch tagga le gocce provenienti da reservoir visibile, applica una finestra di rilascio continua, limita delta frame-to-frame, distribuisce o rende faint il surplus, e misura `visibleBodySpikeScore` / `threeStepScore`.

Comando debug principale:

```js
window.__PERLA_DEBUG__.toggleRainUnifiedDebugV255()
```

Prima chiamata: avvia debug V251/V252/V253/V254/V255. Seconda chiamata: stop e download JSON completo.

Preservato: V248-V254, spawn/refill/update lifecycle/canKeep, mappa/collisioni/assets/tetti/skybox/audio/high-wall runtime off, launcher smart porta 8000.

Check: node --check OK; VM smoke OK; runtime probe export/toggle OK; asset refs 108, missing 0, PNG 116, PNG modificati vs V254 0; patch-only assente.

Nota: test visivo browser reale non eseguito in ambiente container.
