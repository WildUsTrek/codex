# PERLA1 V247 — Rain Temporal Angular Balance Safe

Build: `PERLA1_V247_RAIN_TEMPORAL_ANGULAR_BALANCE_SAFE_LOCAL`
Base reale: `PERLA1_V246_RAIN_VFX_STABILIZER_SAFE_LOCAL`

## Obiettivo
Correggere i difetti residui della V246: doppia scarica near in avvio/uscita tettoia, ritardo percettivo quando la camera ruota, mid/far troppo deboli come presenza ottica.

## Interventi
- Exposure/shelter-exit warmup separato dal weather warmup.
- FrontMin e near target rampati dopo uscita tettoia.
- Refill arbiter anti doppio impulso `frontmin` + `v246_bucket_near`.
- Angular look-ahead: prefill predittivo mid/far durante rotazioni rapide, con refill legacy `turn` soppresso per evitare near burst.
- Boost ottico mid/far su target, alpha, width e leggero maxLen far.
- Debug V247: summary, download report e toggle.

## Debug console
```js
window.__PERLA_DEBUG__.getRainTemporalAngularSummaryV247()
window.__PERLA_DEBUG__.downloadRainTemporalAngularReportV247()
window.__PERLA_DEBUG__.setRainTemporalAngularV247(false)
window.__PERLA_DEBUG__.setRainTemporalAngularV247(true)
```

Debug V246 preservato:
```js
window.__PERLA_DEBUG__.getRainVfxStabilizerSummaryV246()
window.__PERLA_DEBUG__.downloadRainVfxStabilizerReportV246()
window.__PERLA_DEBUG__.setRainVfxStabilizerV246(false)
```

## Preservato
Mappa, collisioni, fMap, cMap, roadMask, objectBlock, asset PNG, ASSET_MANIFEST, tetti, roof/support sync V236, torre, pergola, festoni, skybox, sprite placement, audio, high-wall runtime-off, V234 rain airspace, V235 rain midfield, V246 queue/fade/shelter stabilizer.

## Nota test
Sono stati eseguiti check statici e runtime mock. Il test visivo reale in browser resta obbligatorio, soprattutto bordo tettoia, uscita tettoia, rotazione camera e bilanciamento mid/far.
