# PERLA1_V252_RAIN_NEAR_PHASE_DESYNCHRONIZATION_SAFE_LOCAL

Base reale: `PERLA1_V251_RAIN_LIFECYCLE_DIAGNOSTIC_SAFE_LOCAL`.

Scopo patch: correggere le raffiche near non tramite refill/spawn, ma desincronizzando il passaggio visuale `near_blend -> near` emerso dai report V251.

## Interventi

- Aggiunto sistema V252 `rain_near_phase_desync_promotion_budget`.
- Ogni drop riceve una fase stabile derivata da seed, senza `Math.random()` nel render loop.
- Aggiunto promotion gate: una goccia candidata near non viene promossa automaticamente a near piena.
- Aggiunto budget per frame e finestra temporale per limitare coorti near.
- Le candidate in eccesso restano `near_blend` attenuata, non vengono cancellate.
- `near_blend` è resa più mid-like: alpha/width più bassi e max pixel length più contenuta.
- La near appena promossa ha maxPixelLen progressivo e fade tier ridotto finché non matura.
- Preservata la diagnostica V251.

## Debug

```js
window.__PERLA_DEBUG__.getRainNearPhaseDesyncSummaryV252()
window.__PERLA_DEBUG__.downloadRainNearPhaseDesyncReportV252()
window.__PERLA_DEBUG__.setRainNearPhaseDesyncV252(false)
window.__PERLA_DEBUG__.setRainNearPhaseDesyncV252(true)
```

Restano disponibili i debug V251:

```js
window.__PERLA_DEBUG__.resetRainLifecycleDiagnosticV251()
window.__PERLA_DEBUG__.startRainLifecycleDiagnosticV251()
window.__PERLA_DEBUG__.downloadRainLifecycleDiagnosticReportV251()
```

## Sistemi NON toccati

- Controller V248.
- Refill globale / frontmin / emergency / move / angular.
- Lifecycle respawn V222/V225/V226.
- `canKeepRainDropAtV225()`.
- Mappa, collisioni, `cMap`, `rainCoveredMap`, `rainOpenSkyMap`.
- Tetti, skybox, audio, sprite placement, asset PNG.
- High-wall runtime, che resta off.

## Validazione prevista

- `node --check` su inline script estratto.
- Asset manifest/missing invariati.
- Nessun PNG modificato.
- ZIP/TAR.GZ completi, senza cartella patch-only.
