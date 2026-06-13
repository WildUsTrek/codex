# PERLA1 V245 — High Wall Diagnostics Runtime Off Safe

Build: `PERLA1_V245_HIGH_WALL_DIAGNOSTICS_RUNTIME_OFF_SAFE_LOCAL`
Base reale: `PERLA1_V244_HIGH_WALL_DRAW_ROLLBACK_DEBUG_ONLY_LOCAL`

## Scopo
Chiudere anche dal punto di vista prestazionale il cantiere “muri alti dietro muri bassi”.
La V244 aveva già rimosso i draw sperimentali V242/V242A/V243, ma lasciava ancora calcoli diagnostici per-frame.
La V245 spegne la diagnostica high-wall nel runtime normale e lascia solo un canale manuale/on-demand.

## Interventi
- Aggiunto gate centrale `PERLA_V245_HIGH_WALL_DIAGNOSTICS_RUNTIME_ENABLED = false`.
- Aggiunti comandi debug:
  - `window.__PERLA_DEBUG__.getHighWallDiagnosticsRuntimeStatus()`
  - `window.__PERLA_DEBUG__.enableHighWallDiagnosticsForNextFrame()`
  - `window.__PERLA_DEBUG__.disableHighWallDiagnostics()`
- Bloccato nel runtime normale il flusso V239→V241C: fragment compositor, surface continuity, stable dry-run, registry/face projection, ranking e drawability.
- Mantenuti draw e update buffer sempre spenti.
- Report download high-wall alleggerito: `PERLA1_V245_HIGH_WALL_RUNTIME_OFF_DEBUG_*.json`.

## Vincoli preservati
- Nessun V242/V242A/V243 riattivato.
- Nessun draw muri alti.
- Nessun update ZBuffer/sprite/rain.
- Nessuna modifica a mappa, collisioni, objectBlock, asset PNG, tetti, torre, reception, bagni, pioggia, auto, skybox, sprite.

## Test non eseguiti
Non è stato eseguito un test browser interattivo reale nel container. La verifica decisiva lato utente è scaricare il debug normale e controllare che `highWallDiagnosticsRuntime.runtimeEnabled = false` e che i blocchi pesanti risultino non computati.
