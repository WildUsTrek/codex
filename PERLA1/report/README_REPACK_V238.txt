# PERLA1 V238 — Clean Disable Safe Emerging Wall Experiments

Build: `PERLA1_V238_CLEAN_DISABLE_SAFE_EMERGING_WALL_EXPERIMENTS_LOCAL`
Base reale obbligatoria: `PERLA1_V237A1_BATH_TILE_ALPHA_OPAQUE_SAFE_LOCAL`
Data UTC: 2026-06-11T23:37:08.152196+00:00

## Scopo

Questa build chiude il ramo sperimentale V237B/C/D/E per i “muri alti dietro muri bassi”.
La V237E ha dimostrato che la selezione del candidato funziona parzialmente, ma il risultato visivo resta a muri bucati: quindi la soluzione non viene promossa e non deve restare attiva a runtime.

## Intervento reale

- ripartenza dalla V237A1 stabile, non da V237B/C/D/E;
- aggiornamento build ID/UI/launcher/report a V238;
- `PERLA_V237_SAFE_EMERGING_WALL_LAYER_PROTOTYPE` resta `false`;
- `PERLA_V237_SAFE_EMERGING_LAYER_DEBUG` portato a `false`;
- aggiunto `getV238CleanStatus()` in `window.__PERLA_DEBUG__` per verificare che il ramo V237 sia chiuso;
- nessun draw safe emerging wall layer attivo;
- nessun best candidate selection V237E attivo;
- nessun ring buffer/debug-download V237D/V237E attivo;
- nessun nuovo DDA, nessuna ColumnWallHitStack, nessuno span renderer.

## Preservato

- V233 rollback overdraw;
- V234 rain airspace + car anchor lift;
- V235 tower visibility + rain midfield;
- V236 roof/support sync reale;
- V237A1 bath tile alpha opaque safe;
- mappa, collisioni, worldgen, asset PNG, skybox, pioggia, auto, torre, reception, bagni, roofVisibleAt, sprite placement.

## Nota operativa

V238 non è un nuovo sistema muri alti. È una base pulita dopo il fallimento utile del ramo V237. Il prossimo eventuale sistema dovrà essere progettato separatamente con un’architettura diversa, non basata su recupero frammentario dei candidati per-colonna.
