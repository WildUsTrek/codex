# PERLA1_V251_RAIN_LIFECYCLE_DIAGNOSTIC_SAFE_LOCAL

Base reale: PERLA1_V250_RAIN_NEAR_BUCKET_SEMANTICS_REWORK_SAFE_LOCAL

Questa build e' una diagnostica runtime pura per la pioggia near. Non introduce fix visivi intenzionali.

## Comandi console

```js
window.__PERLA_DEBUG__.resetRainLifecycleDiagnosticV251()
window.__PERLA_DEBUG__.startRainLifecycleDiagnosticV251()
// riproduci le raffiche near
window.__PERLA_DEBUG__.downloadRainLifecycleDiagnosticReportV251()
```

## Cosa registra

- timeline ring buffer ultimi 12 secondi;
- natural respawn: dead/minZ/farDistance/outOfBounds/canKeepRejected;
- cause canKeep: cMap, rainCoveredMap, arch open canopy, arch closed building, not open sky, wall/airspace;
- near segments da natural respawn recente, controller recente o old-alive reveal;
- snapshot contesto: weather, shelterBlend, evento V248, player, direzione, segmenti near/mid/far.

## Vincoli preservati

Nessun asset PNG modificato. Nessuna modifica a mappa/collisioni/tetti/skybox/audio/high-wall. Controller V248 e semantica near V250 preservati.
